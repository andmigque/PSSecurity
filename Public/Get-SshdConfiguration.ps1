Set-StrictMode -Version Latest

function Get-SshdConfiguration {
    <#
    .SYNOPSIS
        Dumps the effective SSH daemon configuration as objects.

    .DESCRIPTION
        Runs sshd -T and parses the effective configuration dump into one record per
        keyword, so the hardening state the daemon actually applies can be read as
        data. sshd -T is the authoritative view: it resolves Include files, Match
        blocks, and platform defaults into the flat keyword list the daemon
        enforces, so the report reflects what runs rather than what any one file
        says.

        Repeated keywords such as ListenAddress or HostKey collect every occurrence
        in dump order into Values. Each record keeps the keyword exactly as sshd -T
        emits it, lowercased, because the dump has no canonical casing to recover. A
        record's Values always holds at least one entry, and empty values are kept
        as empty strings.

        On Windows the service registry decides which binary the machine runs, so
        the default dump targets the binary the sshd service points at, ahead of
        PATH. The report names the service, its state and binary, any -f config the
        service passes, every sshd binary found in the standard install locations
        with its version, and the image paths of running sshd processes, so parallel
        installs cannot hide behind a PATH hit. On Linux and macOS the binary
        resolves through PATH and the standard sbin locations, and process image
        paths are read on a best-effort basis because a non-root session cannot
        read the image path of root-owned processes. When the audited binary
        differs from the service binary or from a running sshd process, the
        discrepancy is recorded in Warnings.

        sshd -T must read the host private keys, which may require an elevated
        session: root on standard distributions, administrator on locked-down
        Windows installs. A run whose host keys are unreadable fails with a
        no-hostkeys warning and a Failed status. Pass -Elevate to re-run the dump
        elevated: through sudo on Linux and macOS, through a UAC consent prompt on
        Windows, for a Complete report. stderr from sshd, such as
        could-not-load-hostkey lines or a syntax error in the config, is collected
        in Warnings, and a non-zero exit marks the report Failed with the exit code
        appended to Warnings instead of pretending the dump is complete. Nothing is
        echoed to the warning stream; the report's Warnings field is the single
        place failures and discrepancies are reported.

        A missing daemon is an audit finding rather than a crashing error: when the
        default binary is absent the report comes back Failed with the reason in
        Warnings and empty Settings, so a scan keeps its report object. A custom
        -SshdBinary that cannot be resolved is a caller mistake and still throws.
        The config file is normalized but not required to exist; a missing config
        surfaces through the sshd -T failure and the same Failed status.

    .PARAMETER SshdBinary
        The SSH daemon binary to dump. Defaults to the module's SshdBinary setting
        for the current platform, which on Windows resolves to the binary the sshd
        service points at when that binary exists. A custom name or path must
        resolve to itself and is never substituted by a fallback.

    .PARAMETER ConfigFile
        The sshd_config file to dump. Defaults to the module's SshdConfigPath
        setting for the current platform; when the audited binary came from the
        Windows sshd service and that service passes -f, the service's config is
        used instead. Passing this parameter replaces the default.

    .PARAMETER ConnectionSpec
        Evaluates Match blocks for a described connection in the sshd -C format,
        for example 'user=root,host=10.0.0.5,addr=10.0.0.5'. Without it the dump
        covers the global configuration only, so values set inside Match blocks are
        not reflected.

    .PARAMETER Elevate
        Re-runs the dump elevated when the current session is not, so restricted
        host keys are readable and the report can be Complete. sudo may prompt for
        a password on Linux and macOS; Windows shows a UAC consent prompt. Ignored
        when the session is already elevated.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject with AuditStatus, ConfigPath, ConnectionSpec, SshdPath,
        SshdVersion, ServiceName, ServiceState, ServiceBinaryPath,
        ServiceConfigPath, RunningProcessPaths, InstalledBinaries, KeywordCount,
        Warnings, and Settings. Settings contains one record per keyword with
        Keyword and Values. ServiceName, ServiceState, ServiceBinaryPath, and
        ServiceConfigPath describe the Windows sshd service and are empty strings
        elsewhere. RunningProcessPaths lists the image paths of running sshd
        processes. InstalledBinaries lists Path and Version for every sshd binary
        found through the service, PATH, and the standard install locations.
        AuditStatus is Complete only when sshd -T exited zero; any other exit marks
        the report Failed, and Settings is then possibly empty or partial. Warnings
        carries the stderr lines, the exit code appended last when the dump failed,
        and audit findings such as multiple installs and service discrepancies.
        When the default daemon is not installed the report is Failed with empty
        Settings and the reason in Warnings.

    .EXAMPLE
        $report = Get-SshdConfiguration -Elevate
        $report.Settings | Where-Object Keyword -eq 'permitrootlogin'

        Dumps the effective configuration elevated and reads one setting.

    .EXAMPLE
        $spec = 'user=admin,host=10.0.0.5,addr=10.0.0.5'
        $report = Get-SshdConfiguration -ConnectionSpec $spec -Elevate
        $report.Settings |
            Where-Object Keyword -in 'permitrootlogin', 'passwordauthentication', 'x11forwarding'

        Evaluates the Match blocks that apply to one connection and lists the
        authentication-relevant settings.

    .EXAMPLE
        $report = Get-SshdConfiguration
        $report.InstalledBinaries
        $report.ServiceBinaryPath

        Shows every sshd binary installed on the machine and the binary the sshd
        service actually runs, exposing parallel installs the PATH alone hides.

    .NOTES
        Cross-platform over Windows, Linux, and macOS, wherever an OpenSSH server
        is installed; in WSL, run it inside the target distribution. The default
        binary and config paths come from the SshdBinary and SshdConfigPath keys in
        Config/Setting.psd1, nested per platform, so non-standard installations can
        be tuned there. The version is parsed from the sshd -V banner and reported
        as Unknown when the banner cannot be read; Windows banners read
        OpenSSH_for_Windows_<version>. Windows service discovery reads
        Win32_Service and requires no elevation.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The SSH daemon binary to dump. Defaults to the SshdBinary setting for the platform.
        [Parameter(HelpMessage = 'Enter the sshd binary name or path. Defaults to the SshdBinary setting.')]
        [ValidateNotNullOrEmpty()]
        [string]$SshdBinary = $script:SshdBinary,

        # The sshd_config file to dump. Defaults to the SshdConfigPath setting for the platform.
        [Parameter(HelpMessage = 'Enter the sshd_config path. Defaults to the SshdConfigPath setting.')]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigFile = $script:SshdConfigPath,

        # Describes a connection for Match block evaluation in the sshd -C format.
        [Parameter(HelpMessage = 'Enter the sshd -C connection spec, for example user=root,host=localhost,addr=127.0.0.1.')]
        [ValidatePattern('^([A-Za-z]+=[^,]*)(,[A-Za-z]+=[^,]*)*$')]
        [string]$ConnectionSpec = '',

        # Re-run the dump elevated when the current session is not.
        [Parameter(HelpMessage = 'Re-run the dump elevated for a complete report.')]
        [switch]$Elevate
    )

    $sessionIsElevated = if ($IsWindows) { Test-Administrator } else { (& id -u) -eq 0 }

    if ($Elevate -and -not $sessionIsElevated) {
        # Parameters are single-quoted for the elevated child process, and embedded
        # single quotes are doubled to survive the round trip.
        $binaryArgument = $SshdBinary.Replace("'", "''")
        $configArgument = $ConfigFile.Replace("'", "''")
        $call = "Get-SshdConfiguration -SshdBinary '$binaryArgument' -ConfigFile '$configArgument'"

        if ($ConnectionSpec) {
            $connectionArgument = $ConnectionSpec.Replace("'", "''")
            $call += " -ConnectionSpec '$connectionArgument'"
        }

        if ($IsWindows) {
            Invoke-ElevatedCommand -Command $call
        }
        else {
            Invoke-SudoCommand -Command $call
        }

        return
    }

    $warnings = [System.Collections.Generic.List[string]]::new()

    $runningProcessPaths = [System.Collections.Generic.List[string]]::new()
    foreach ($sshdProcess in (Get-Process -Name sshd -ErrorAction SilentlyContinue)) {
        $processPath = $sshdProcess.Path
        if ($processPath -and -not $runningProcessPaths.Contains($processPath)) {
            $runningProcessPaths.Add($processPath)
        }
    }

    # On Windows the service registry decides which binary the machine runs, so the
    # sshd service is discovered ahead of resolution and surfaced in the report.
    $serviceName = ''
    $serviceState = ''
    $serviceBinaryPath = ''
    $serviceConfigPath = ''
    $resolvedFromService = $false

    if ($IsWindows) {
        $sshdServices = @(Get-CimInstance -ClassName Win32_Service -Filter "PathName LIKE '%sshd%'" -ErrorAction SilentlyContinue)
        $pickedService = $null
        if ($sshdServices.Count -gt 0) {
            $runningServices = @($sshdServices | Where-Object -FilterScript { $_.State -eq 'Running' })
            if ($runningServices.Count -gt 0) {
                $pickedService = $runningServices[0]
            }
            else {
                $defaultNameServices = @($sshdServices | Where-Object -FilterScript { $_.Name -eq 'sshd' })
                if ($defaultNameServices.Count -gt 0) {
                    $pickedService = $defaultNameServices[0]
                }
                else {
                    $pickedService = $sshdServices[0]
                }
            }
        }

        if ($pickedService) {
            $serviceName = $pickedService.Name
            $serviceState = $pickedService.State
            $servicePathName = [string]$pickedService.PathName

            # A quoted path is taken verbatim; an unquoted path is cut at its first
            # .exe token, which handles spaced install directories.
            if ($servicePathName -match '^"([^"]+)"(?:\s+(.*))?$') {
                $serviceBinaryPath = $Matches[1]
                $serviceArguments = if ($Matches[2]) { $Matches[2] } else { '' }
            }
            elseif ($servicePathName -match '^(.+?\.exe)(?:\s+(.*))?$') {
                $serviceBinaryPath = $Matches[1]
                $serviceArguments = if ($Matches[2]) { $Matches[2] } else { '' }
            }
            else {
                $serviceBinaryPath = $servicePathName
                $serviceArguments = ''
            }

            if ($serviceArguments -match '-f\s+(?:"([^"]+)"|(\S+))') {
                $serviceConfigPath = if ($Matches[1]) { $Matches[1] } else { $Matches[2] }
            }

            if ($sshdServices.Count -gt 1) {
                $serviceNames = ($sshdServices | ForEach-Object { $_.Name } | Sort-Object) -join ', '
                $warnings.Add("Multiple sshd services are registered: $serviceNames. Auditing '$serviceName'.")
            }

            if ($serviceBinaryPath -and -not (Test-Path -LiteralPath $serviceBinaryPath -PathType Leaf)) {
                $warnings.Add("The sshd service '$serviceName' points at '$serviceBinaryPath', which does not exist on disk.")
            }
        }
    }

    # The standard install locations rescue only the platform default name. An
    # explicitly requested binary must resolve to itself, or the call is a caller
    # mistake.
    $standardBinaryPaths = @('/usr/sbin/sshd', '/sbin/sshd', '/usr/local/sbin/sshd')
    if ($IsWindows) {
        $standardBinaryPaths = @(
            "$env:SystemRoot\System32\OpenSSH\sshd.exe"
            'C:\Program Files\OpenSSH\sshd.exe'
            'C:\Program Files\OpenSSH-Win64\sshd.exe'
        )
    }

    $sshdPath = ''
    if ($IsWindows -and $SshdBinary -eq $script:SshdBinary -and $serviceBinaryPath -and
        (Test-Path -LiteralPath $serviceBinaryPath -PathType Leaf)) {
        # The machine runs whatever the sshd service points at, so that binary
        # outranks PATH as the audit default.
        $sshdPath = $serviceBinaryPath
        $resolvedFromService = $true
        Write-Verbose -Message "Resolved sshd from the sshd service '$serviceName': $sshdPath"
    }

    if (-not $sshdPath) {
        $sshdCommand = Get-Command -Name $SshdBinary -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        $sshdPath = if ($sshdCommand) { $sshdCommand.Source } else { '' }
    }

    if (-not $sshdPath -and $SshdBinary -eq $script:SshdBinary) {
        foreach ($candidatePath in $standardBinaryPaths) {
            if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
                $sshdPath = $candidatePath
                Write-Verbose -Message "Resolved sshd through the standard install locations: $sshdPath"
                break
            }
        }
    }

    if (-not $sshdPath) {
        $notInstalledWarning = "The SSH daemon binary '$SshdBinary' was not found on PATH or in the standard install locations."

        # A missing default daemon is an audit finding, not a crashing error: the
        # report comes back Failed so a scan keeps its object. A custom binary that
        # cannot be resolved is a caller mistake and still throws.
        if ($SshdBinary -eq $script:SshdBinary) {
            $installHint = ' Is openssh-server installed, or is -SshdBinary pointing at a custom daemon?'
            if ($IsWindows) {
                $installHint = ' Is the OpenSSH Server feature installed, or is -SshdBinary pointing at a custom daemon?'
            }

            $notInstalledWarning += $installHint

            if ($runningProcessPaths.Count -gt 0) {
                $warnings.Add('sshd processes are running even though the daemon binary could not be resolved.')
            }

            $warnings.Add($notInstalledWarning)

            [pscustomobject]@{
                AuditStatus         = 'Failed'
                ConfigPath          = $ConfigFile
                ConnectionSpec      = $ConnectionSpec
                SshdPath            = ''
                SshdVersion         = 'Unknown'
                ServiceName         = $serviceName
                ServiceState        = $serviceState
                ServiceBinaryPath   = $serviceBinaryPath
                ServiceConfigPath   = $serviceConfigPath
                RunningProcessPaths = $runningProcessPaths.ToArray()
                InstalledBinaries   = @()
                KeywordCount        = 0
                Warnings            = $warnings.ToArray()
                Settings            = @()
            }

            return
        }

        throw "$notInstalledWarning Pass the daemon path with -SshdBinary or install openssh-server."
    }

    foreach ($runningProcessPath in $runningProcessPaths) {
        if ($runningProcessPath -ne $sshdPath) {
            $warnings.Add("A running sshd process uses '$runningProcessPath', which differs from the audited binary '$sshdPath'.")
        }
    }

    if ($serviceBinaryPath -and (Test-Path -LiteralPath $serviceBinaryPath -PathType Leaf) -and -not $resolvedFromService) {
        $warnings.Add("The sshd service '$serviceName' runs '$serviceBinaryPath', which differs from the audited binary '$sshdPath'.")
    }

    if ($resolvedFromService -and $serviceConfigPath -and $ConfigFile -eq $script:SshdConfigPath) {
        # The audited binary came from the service, so the config the service passes
        # with -f outranks the platform default.
        $ConfigFile = $serviceConfigPath
        Write-Verbose -Message "Using the config the sshd service passes: $ConfigFile"
    }

    $configPath = [System.IO.Path]::GetFullPath($ConfigFile)

    $dumpErrorPath = [System.IO.Path]::GetTempFileName()
    $versionErrorPath = [System.IO.Path]::GetTempFileName()
    try {
        # Every binary the service, PATH, and the standard install locations expose
        # is version-probed, so parallel installs are named with their versions.
        # Sort-Object -Unique folds Windows path casing differences back together.
        $installedBinaryPaths = @($sshdPath)
        if ($serviceBinaryPath -and (Test-Path -LiteralPath $serviceBinaryPath -PathType Leaf)) {
            $installedBinaryPaths += $serviceBinaryPath
        }

        foreach ($standardBinaryPath in $standardBinaryPaths) {
            if (Test-Path -LiteralPath $standardBinaryPath -PathType Leaf) {
                $installedBinaryPaths += $standardBinaryPath
            }
        }

        $versionByBinaryPath = @{}
        foreach ($installedBinaryPath in ($installedBinaryPaths | Sort-Object -Unique)) {
            [void](& $installedBinaryPath -V 2> $versionErrorPath)
            $binaryVersion = 'Unknown'
            foreach ($versionLine in (Get-Content -LiteralPath $versionErrorPath)) {
                if ($versionLine -match 'OpenSSH_[^\s,]+') {
                    $binaryVersion = $Matches[0]
                    break
                }
            }

            $versionByBinaryPath[$installedBinaryPath] = $binaryVersion
        }

        if ($versionByBinaryPath.ContainsKey($sshdPath)) {
            $sshdVersion = $versionByBinaryPath[$sshdPath]
        }
        else {
            $sshdVersion = 'Unknown'
        }

        $installedBinaries = [System.Collections.Generic.List[object]]::new()
        foreach ($installedBinaryPath in ($versionByBinaryPath.Keys | Sort-Object)) {
            $installedBinaryRecord = [pscustomobject]@{
                Path    = $installedBinaryPath
                Version = $versionByBinaryPath[$installedBinaryPath]
            }

            $installedBinaries.Add($installedBinaryRecord)
        }

        if ($installedBinaries.Count -gt 1) {
            $versionsText = ($installedBinaries | ForEach-Object { "$($_.Path) ($($_.Version))" }) -join ', '
            if ($resolvedFromService) {
                $ownershipClause = " The sshd service runs '$sshdPath'."
            }
            else {
                $ownershipClause = " The audited binary is '$sshdPath'."
            }

            $warnings.Add("Multiple sshd binaries are installed: $versionsText.$ownershipClause")
        }

        $connectionArguments = @()
        if ($ConnectionSpec) {
            $connectionArguments = @('-C', $ConnectionSpec)
        }

        $dumpOutput = & $sshdPath -T -f $configPath @connectionArguments 2> $dumpErrorPath
        $dumpExitCode = $LASTEXITCODE

        foreach ($errorLine in (Get-Content -LiteralPath $dumpErrorPath)) {
            $trimmedError = $errorLine.Trim()
            if ($trimmedError.Length -gt 0) {
                $warnings.Add($trimmedError)
            }
        }

        if ($dumpExitCode -ne 0) {
            $failureSummary = "sshd -T exited with code $dumpExitCode; the dump may be missing or partial."
            if (-not $sessionIsElevated) {
                $failureSummary += ' Re-run with -Elevate so restricted host keys are readable and the dump completes.'
            }
            $warnings.Add($failureSummary)
        }

        # One dictionary entry per keyword; repeated keywords such as ListenAddress
        # or HostKey accumulate every occurrence in dump order.
        $valuesByKeyword = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]]::new()
        foreach ($line in $dumpOutput) {
            $trimmedLine = $line.Trim()
            if ($trimmedLine.Length -eq 0) {
                continue
            }

            $keyword, $value = $trimmedLine -split '\s+', 2
            $settingValue = ''
            if ($null -ne $value) {
                $settingValue = $value
            }

            if (-not $valuesByKeyword.ContainsKey($keyword)) {
                $valuesByKeyword[$keyword] = [System.Collections.Generic.List[string]]::new()
            }

            $valuesByKeyword[$keyword].Add($settingValue)
        }

        $settings = [System.Collections.Generic.List[object]]::new()
        foreach ($keyword in ($valuesByKeyword.Keys | Sort-Object)) {
            $settingRecord = [pscustomobject]@{
                Keyword = $keyword
                Values  = @($valuesByKeyword[$keyword].ToArray())
            }

            $settings.Add($settingRecord)
        }

        $auditStatus = 'Complete'
        if ($dumpExitCode -ne 0) {
            $auditStatus = 'Failed'
        }

        [pscustomobject]@{
            AuditStatus         = $auditStatus
            ConfigPath          = $configPath
            ConnectionSpec      = $ConnectionSpec
            SshdPath            = $sshdPath
            SshdVersion         = $sshdVersion
            ServiceName         = $serviceName
            ServiceState        = $serviceState
            ServiceBinaryPath   = $serviceBinaryPath
            ServiceConfigPath   = $serviceConfigPath
            RunningProcessPaths = $runningProcessPaths.ToArray()
            InstalledBinaries   = $installedBinaries.ToArray()
            KeywordCount        = $settings.Count
            Warnings            = $warnings.ToArray()
            Settings            = $settings.ToArray()
        }
    }
    finally {
        Remove-Item -LiteralPath @($dumpErrorPath, $versionErrorPath) -Force -ErrorAction SilentlyContinue
    }
}
