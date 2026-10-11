if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Get-SshdConfiguration {
        <#
    .SYNOPSIS
        Dumps the effective SSH daemon configuration as objects.

    .DESCRIPTION
        Runs sshd -T and parses the effective configuration dump into one record per
        keyword, so the hardening state the daemon actually applies can be read as
        data. sshd -T is the authoritative view: it resolves Include files, Match
        blocks, and distribution defaults into the flat keyword list the daemon
        enforces, so the report reflects what runs rather than what any one file
        says.

        Repeated keywords such as ListenAddress or HostKey collect every occurrence
        in dump order into Values. Each record keeps the keyword exactly as sshd -T
        emits it, lowercased, because the dump has no canonical casing to recover. A
        record's Values always holds at least one entry, and empty values are kept
        as empty strings.

        sshd -T must read the host private keys, which only root can do on standard
        distributions, so a non-root run fails with a no-hostkeys warning and a
        Failed status. Pass -Elevate to re-run the dump as root through sudo for a
        Complete report. stderr from sshd, such as could-not-load-hostkey lines or
        a syntax error in the config, is collected in Warnings and echoed through
        Write-Warning, and a non-zero exit marks the report Failed instead of
        pretending the dump is complete.

    .PARAMETER SshdBinary
        The SSH daemon binary to dump. Defaults to the module's SshdBinary setting.
        Accepts a name resolved through PATH or an absolute path; when the name is
        not on PATH, the standard sbin locations are probed because non-root PATHs
        often omit them.

    .PARAMETER ConfigFile
        The sshd_config file to dump. Defaults to the module's SshdConfigPath
        setting.

    .PARAMETER ConnectionSpec
        Evaluates Match blocks for a described connection in the sshd -C format,
        for example 'user=root,host=10.0.0.5,addr=10.0.0.5'. Without it the dump
        covers the global configuration only, so values set inside Match blocks are
        not reflected.

    .PARAMETER Elevate
        Re-runs the dump as root through sudo when the current session is not root,
        so the host keys are readable and the report can be Complete. sudo may
        prompt for a password. Ignored when the session is already root.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject with AuditStatus, ConfigPath, ConnectionSpec, SshdPath,
        SshdVersion, KeywordCount, Warnings, and Settings. Settings contains one
        record per keyword with Keyword and Values. AuditStatus is Complete only
        when sshd -T exited zero; any other exit marks the report Failed, and
        Settings is then possibly empty or partial. Warnings carries the stderr
        lines, with the exit code appended last when the dump failed.

    .EXAMPLE
        $report = Get-SshdConfiguration -Elevate
        $report.Settings | Where-Object Keyword -eq 'permitrootlogin'

        Dumps the effective configuration as root and reads one setting.

    .EXAMPLE
        $spec = 'user=admin,host=10.0.0.5,addr=10.0.0.5'
        $report = Get-SshdConfiguration -ConnectionSpec $spec -Elevate
        $report.Settings |
            Where-Object Keyword -in 'permitrootlogin', 'passwordauthentication', 'x11forwarding'

        Evaluates the Match blocks that apply to one connection and lists the
        authentication-relevant settings.

    .EXAMPLE
        (Get-SshdConfiguration -Elevate).Settings |
            Where-Object Keyword -eq 'listenaddress' |
            Select-Object -ExpandProperty Values

        Lists every address and port the daemon listens on.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. Requires
        an installed OpenSSH server; the binary is resolved through PATH with the
        standard sbin locations as fallback. The default binary and config paths
        come from the SshdBinary and SshdConfigPath keys in Config/Setting.psd1, so
        non-standard installations can be tuned there. The version is parsed from
        the sshd -V banner and reported as Unknown when the banner cannot be read.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            # The SSH daemon binary to dump. Defaults to the module's SshdBinary setting.
            [Parameter(HelpMessage = 'Enter the sshd binary name or path. Defaults to the SshdBinary setting.')]
            [ValidateNotNullOrEmpty()]
            [string]$SshdBinary = $script:SshdBinary,

            # The sshd_config file to dump. Defaults to the module's SshdConfigPath setting.
            [Parameter(HelpMessage = 'Enter the sshd_config path. Defaults to the SshdConfigPath setting.')]
            [ValidateNotNullOrEmpty()]
            [string]$ConfigFile = $script:SshdConfigPath,

            # Describes a connection for Match block evaluation in the sshd -C format.
            [Parameter(HelpMessage = 'Enter the sshd -C connection spec, for example user=root,host=localhost,addr=127.0.0.1.')]
            [ValidatePattern('^([A-Za-z]+=[^,]*)(,[A-Za-z]+=[^,]*)*$')]
            [string]$ConnectionSpec = '',

            # Re-run the dump as root through sudo when the current session is not root.
            [Parameter(HelpMessage = 'Re-run the dump as root through sudo for a complete report.')]
            [switch]$Elevate
        )

        $sessionIsRoot = (& id -u) -eq 0

        if ($Elevate -and -not $sessionIsRoot) {
            # Parameters are single-quoted for the sudo child process, and embedded
            # single quotes are doubled to survive the round trip.
            $binaryArgument = $SshdBinary.Replace("'", "''")
            $configArgument = $ConfigFile.Replace("'", "''")
            $call = "Get-SshdConfiguration -SshdBinary '$binaryArgument' -ConfigFile '$configArgument'"

            if ($ConnectionSpec) {
                $connectionArgument = $ConnectionSpec.Replace("'", "''")
                $call += " -ConnectionSpec '$connectionArgument'"
            }

            Invoke-SudoCommand -Command $call
            return
        }

        $sshdCommand = Get-Command -Name $SshdBinary -CommandType Application -ErrorAction SilentlyContinue |
            Select-Object -First 1
        $sshdPath = if ($sshdCommand) { $sshdCommand.Source } else { '' }
        if (-not $sshdPath) {
            # Non-root PATHs often omit the sbin directories that hold sshd.
            foreach ($candidatePath in @('/usr/sbin/sshd', '/sbin/sshd', '/usr/local/sbin/sshd')) {
                if (Test-Path -LiteralPath $candidatePath -PathType Leaf) {
                    $sshdPath = $candidatePath
                    Write-Verbose -Message "Resolved sshd through the standard sbin locations: $sshdPath"
                    break
                }
            }
        }

        if (-not $sshdPath) {
            throw "The SSH daemon binary '$SshdBinary' was not found on PATH or in the sbin locations. Is openssh-server installed?"
        }

        $configPath = (Resolve-Path -LiteralPath $ConfigFile -ErrorAction Stop).Path

        $dumpErrorPath = [System.IO.Path]::GetTempFileName()
        $versionErrorPath = [System.IO.Path]::GetTempFileName()
        try {
            [void](& $sshdPath -V 2> $versionErrorPath)
            $sshdVersion = 'Unknown'
            foreach ($versionLine in (Get-Content -LiteralPath $versionErrorPath)) {
                if ($versionLine -match 'OpenSSH_[^\s,]+') {
                    $sshdVersion = $Matches[0]
                    break
                }
            }

            $connectionArguments = @()
            if ($ConnectionSpec) {
                $connectionArguments = @('-C', $ConnectionSpec)
            }

            $dumpOutput = & $sshdPath -T -f $configPath @connectionArguments 2> $dumpErrorPath
            $dumpExitCode = $LASTEXITCODE

            $warnings = [System.Collections.Generic.List[string]]::new()
            foreach ($errorLine in (Get-Content -LiteralPath $dumpErrorPath)) {
                $trimmedError = $errorLine.Trim()
                if ($trimmedError.Length -gt 0) {
                    $warnings.Add($trimmedError)
                }
            }

            if ($dumpExitCode -ne 0) {
                $failureSummary = "sshd -T exited with code $dumpExitCode; the dump may be missing or partial."
                if (-not $sessionIsRoot) {
                    $failureSummary += ' Re-run with -Elevate for the root-readable configuration.'
                }
                $warnings.Add($failureSummary)
                Write-Warning -Message $failureSummary
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
                AuditStatus    = $auditStatus
                ConfigPath     = $configPath
                ConnectionSpec = $ConnectionSpec
                SshdPath       = $sshdPath
                SshdVersion    = $sshdVersion
                KeywordCount   = $settings.Count
                Warnings       = $warnings.ToArray()
                Settings       = $settings.ToArray()
            }
        }
        finally {
            Remove-Item -LiteralPath @($dumpErrorPath, $versionErrorPath) -Force -ErrorAction SilentlyContinue
        }
    }
}
