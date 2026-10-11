if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Get-WorldWritableFile {
        <#
    .SYNOPSIS
        Finds world-writable files on Linux.

    .DESCRIPTION
        Returns one report describing world-writable files under the scan roots. The
        roots are walked with an explicit directory stack, matching the module's
        Compress-FileTree traversal. With -IncludeDirectories, the report also includes
        world-writable directories that lack the sticky bit; sticky world-writable
        directories follow the /tmp convention and are treated as acceptable. Hidden
        dotfiles are included, which matters for audits because user settings such as
        .ssh are exactly where loose modes cause damage. Symlinks are skipped. Mount
        points parsed from /proc/mounts are not traversed, so each scan stays on the
        filesystems of its roots and pseudo filesystems such as /proc, plus WSL's
        /mnt/* drives, are excluded; a mount can still be scanned by passing it as a
        root. Excluded paths are not traversed at all.

        The report is always one object carrying coverage counters and an AuditStatus, so
        a run with zero findings is never mistaken for a clean result. AuditStatus is
        Complete only when every directory was enumerated and no errors were recorded;
        otherwise it is Incomplete, and SkippedDirectories, SkippedDirectoryPaths, and
        Errors explain the gap. A non-root session cannot enumerate root-only directories,
        so those are skipped with verbose notes and counted at the end. Pass -Elevate to
        re-run the scan as root through sudo and return the complete report; a PowerShell
        function cannot be run through sudo directly, so -Elevate reconstructs the
        invocation and runs it under sudo pwsh. Results retains individual findings
        sorted by path; Errors retains enumeration failures only.

    .PARAMETER Path
        Root directories to scan. Defaults to the module's WorldWritableIncludePath setting
        from Config/Setting.psd1.

    .PARAMETER ExcludePath
        Path patterns to skip, for example /tmp/*. Wildcards are allowed. Matching
        directories are not traversed. Defaults to the module's WorldWritableExcludePath
        setting from Config/Setting.psd1; passing this parameter replaces the default list,
        so @() disables all exclusions.

    .PARAMETER IncludeDirectories
        Also reports world-writable directories without the sticky bit.

    .PARAMETER Elevate
        Re-runs the audit as root through sudo when the current session is not root, so
        root-only directories are enumerated and the report can be Complete. A PowerShell
        function cannot be run through sudo directly, so this reconstructs the invocation
        and runs it under sudo pwsh; sudo may prompt for a password. Ignored when the
        session is already root.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject with AuditStatus, ScannedRoots, ExcludedPatterns, ScannedFiles,
        ScannedDirectories, WorldWritableFiles, WorldWritableDirectories, SkippedDirectories,
        SkippedDirectoryPaths, ByOwner, Results, and Errors. Results contains the individual
        findings with Path, Kind, Mode, Owner, SizeBytes, and LastWriteTime; Owner is
        Unknown when it cannot be read. Errors contains Path and Message for enumeration
        failures outside the non-root permission skips. ExcludedPatterns shows the effective
        exclusion list, and ExcludedPatterns with the coverage counters explain an empty
        result. An empty scan returns zero counts and empty arrays.

    .EXAMPLE
        $report = Get-WorldWritableFile
        $report.AuditStatus
        $report.Results | Format-Table Path, Kind, Mode, Owner

        Audits the whole root filesystem using the include and exclude lists from the
        module settings and inspects the findings.

    .EXAMPLE
        $report = Get-WorldWritableFile -Path /etc, /usr -IncludeDirectories
        $report.ByOwner

        Audits the configuration and binary trees, flags world-writable directories
        missing the sticky bit, and reviews which accounts own the findings.

    .EXAMPLE
        $report = Get-WorldWritableFile -Elevate
        $report.Results

        Re-runs the scan as root through sudo so root-only directories are enumerated,
        returning the complete report.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. Requires
        PowerShell 7.4 for File.GetUnixFileMode; the module manifest already enforces
        this. Default scan roots and exclusion patterns come from the WorldWritableIncludePath
        and WorldWritableExcludePath keys in Config/Setting.psd1. Owner names come from one
        batched GNU stat call per chunk of findings. A non-root audit skips directories it
        cannot enumerate with verbose notes and reports the skipped count as a single warning
        at the end; other enumeration failures are collected in Errors. A full root scan
        reads every file's metadata and can take a while on large filesystems.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            # Root directories to scan. Defaults to the module's WorldWritableIncludePath setting.
            [Parameter(HelpMessage = 'Enter the root directories to scan. Defaults to the WorldWritableIncludePath setting.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Path = $script:WorldWritableIncludePath,

            # Path patterns to skip. Defaults to the module's WorldWritableExcludePath setting.
            [Parameter(HelpMessage = 'Enter path patterns to exclude. Defaults to the WorldWritableExcludePath setting.')]
            [string[]]$ExcludePath = $script:WorldWritableExcludePath,

            # Also audit world-writable directories without the sticky bit.
            [Parameter(HelpMessage = 'Also audit world-writable directories without the sticky bit.')]
            [switch]$IncludeDirectories,

            # Re-run the audit as root through sudo when the current session is not root.
            [Parameter(HelpMessage = 'Re-run the audit as root through sudo for a complete scan.')]
            [switch]$Elevate
        )

        $sessionIsRoot = (& id -u) -eq 0

        if ($Elevate -and -not $sessionIsRoot) {
            # Array parameters bind as one comma-separated value (PowerShell rejects a
            # repeated parameter), so rebuild the invocation for the sudo child process.
            $pathArg = ($Path | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','
            $call = "Get-WorldWritableFile -Path $pathArg"

            if ($ExcludePath.Count -eq 0) {
                $call += ' -ExcludePath @()'
            }
            else {
                $excludeArg = ($ExcludePath | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','
                $call += " -ExcludePath $excludeArg"
            }

            if ($IncludeDirectories) {
                $call += ' -IncludeDirectories'
            }

            Invoke-SudoCommand -Command $call
            return
        }

        $scanRoots = @()
        foreach ($rootPath in $Path) {
            $scanRoots += (Resolve-Path -LiteralPath $rootPath -ErrorAction Stop).Path
        }

        # Mount points parsed from /proc/mounts prune the walk at filesystem boundaries: the
        # pure PowerShell stand-in for find -xdev. Root directories are pushed unconditionally,
        # so a mount can still be scanned by passing it as a root.
        $mountPoints = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        try {
            foreach ($mountLine in Get-Content -LiteralPath '/proc/mounts' -ErrorAction Stop) {
                $mountFields = $mountLine -split ' '
                if ($mountFields.Count -ge 2) {
                    $mountPoint = $mountFields[1].Replace('\040', ' ').Replace('\011', "`t").Replace('\012', "`n").Replace('\134', '\')
                    [void]$mountPoints.Add($mountPoint)
                }
            }
        }
        catch {
            Write-Warning -Message 'Could not read /proc/mounts; other filesystems will not be pruned from the scan.'
        }

        $records = [System.Collections.Generic.List[PSCustomObject]]::new()
        $errors = [System.Collections.Generic.List[object]]::new()
        $skippedDirectoryCount = 0
        $skippedDirectoryPaths = [System.Collections.Generic.List[string]]::new()
        $scannedFiles = 0
        $scannedDirectories = 0
        $directories = [System.Collections.Generic.Stack[System.IO.DirectoryInfo]]::new()
        foreach ($scanRoot in $scanRoots) {
            $directories.Push([System.IO.DirectoryInfo]::new($scanRoot))
        }

        while ($directories.Count -gt 0) {
            $directory = $directories.Pop()

            try {
                foreach ($entry in $directory.EnumerateFileSystemInfos()) {
                    if ($entry.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                        continue
                    }

                    $isExcluded = $false
                    foreach ($pattern in $ExcludePath) {
                        if ($entry.FullName -like $pattern) {
                            $isExcluded = $true
                            break
                        }
                    }

                    if ($isExcluded) {
                        Write-Verbose -Message "Skipping excluded path: $($entry.FullName)"
                        continue
                    }

                    if ($entry -is [System.IO.DirectoryInfo]) {
                        if ($mountPoints.Contains($entry.FullName)) {
                            Write-Verbose -Message "Skipping other filesystem: $($entry.FullName)"
                            continue
                        }

                        $directories.Push($entry)

                        if (-not $IncludeDirectories) {
                            continue
                        }

                        $unixMode = [System.IO.File]::GetUnixFileMode($entry.FullName)
                        $isWorldWritable = [bool]($unixMode -band [System.IO.UnixFileMode]::OtherWrite)
                        $hasStickyBit = [bool]($unixMode -band [System.IO.UnixFileMode]::StickyBit)

                        if ($isWorldWritable -and -not $hasStickyBit) {
                            $record = [PSCustomObject]@{
                                Path          = $entry.FullName
                                Kind          = 'Directory'
                                Mode          = [Convert]::ToString([int]$unixMode, 8)
                                Owner         = 'Unknown'
                                SizeBytes     = 0
                                LastWriteTime = $entry.LastWriteTime
                            }

                            $records.Add($record)
                        }
                    }
                    else {
                        $unixMode = [System.IO.File]::GetUnixFileMode($entry.FullName)
                        $scannedFiles++

                        if ($unixMode -band [System.IO.UnixFileMode]::OtherWrite) {
                            $record = [PSCustomObject]@{
                                Path          = $entry.FullName
                                Kind          = 'File'
                                Mode          = [Convert]::ToString([int]$unixMode, 8)
                                Owner         = 'Unknown'
                                SizeBytes     = $entry.Length
                                LastWriteTime = $entry.LastWriteTime
                            }

                            $records.Add($record)
                        }
                    }
                }

                $scannedDirectories++
            }
            catch {
                $enumerationError = $_.Exception
                $accessDenied = $enumerationError -is [System.UnauthorizedAccessException]
                $accessDenied = $accessDenied -or $enumerationError.InnerException -is [System.UnauthorizedAccessException]

                if ($accessDenied -and -not $sessionIsRoot) {
                    Write-Verbose -Message "Skipping inaccessible directory: $($directory.FullName)"
                    $skippedDirectoryCount++
                    $skippedDirectoryPaths.Add($directory.FullName)
                }
                else {
                    $enumerationFailure = [pscustomobject]@{
                        Path    = $directory.FullName
                        Message = $enumerationError.Message
                    }

                    $errors.Add($enumerationFailure)
                }
            }
        }

        $rows = @($records | Sort-Object -Property Path)

        # FileSystemInfo exposes modes and times but not owning accounts, so owner names are
        # enriched from one batched stat call per chunk of findings.
        $ownerByPath = @{}
        if ($rows.Count -gt 0) {
            $findingPaths = @($rows.Path)

            for ($chunkStart = 0; $chunkStart -lt $findingPaths.Count; $chunkStart += 256) {
                $chunkEnd = [Math]::Min($chunkStart + 255, $findingPaths.Count - 1)
                $chunkPaths = @($findingPaths[$chunkStart..$chunkEnd])
                $chunkOwners = @(& stat -c '%U:%G' -- $chunkPaths)

                if ($LASTEXITCODE -ne 0 -or $chunkOwners.Count -ne $chunkPaths.Count) {
                    $ownerFailure = [pscustomobject]@{
                        Path    = $chunkPaths[0]
                        Message = 'Could not read the owners for this chunk of findings.'
                    }

                    $errors.Add($ownerFailure)
                    continue
                }

                for ($chunkIndex = 0; $chunkIndex -lt $chunkPaths.Count; $chunkIndex++) {
                    $ownerByPath[$chunkPaths[$chunkIndex]] = $chunkOwners[$chunkIndex]
                }
            }
        }

        foreach ($row in $rows) {
            if ($ownerByPath.ContainsKey($row.Path)) {
                $row.Owner = $ownerByPath[$row.Path]
            }
        }

        # ByOwner counts findings per owning account, most frequent first.
        $byOwner = [System.Collections.Generic.List[object]]::new()
        foreach ($ownerGroup in ($rows | Group-Object -Property Owner | Sort-Object -Property Count -Descending)) {
            $ownerCount = [pscustomobject]@{
                Name  = $ownerGroup.Name
                Count = $ownerGroup.Count
            }

            $byOwner.Add($ownerCount)
        }

        $auditStatus = 'Complete'
        if ($skippedDirectoryCount -gt 0 -or $errors.Count -gt 0) {
            $auditStatus = 'Incomplete'
        }

        if ($skippedDirectoryCount -gt 0) {
            $skipSummary = 'Skipped {0} directories due to insufficient permissions.' -f $skippedDirectoryCount
            $skipSummary += ' Re-run with -Elevate for a complete audit.'
            Write-Warning -Message $skipSummary
        }

        [pscustomobject]@{
            AuditStatus              = $auditStatus
            ScannedRoots             = $scanRoots
            ExcludedPatterns         = $ExcludePath
            ScannedFiles             = $scannedFiles
            ScannedDirectories       = $scannedDirectories
            WorldWritableFiles       = @($rows | Where-Object { $_.Kind -eq 'File' }).Count
            WorldWritableDirectories = @($rows | Where-Object { $_.Kind -eq 'Directory' }).Count
            SkippedDirectories       = $skippedDirectoryCount
            SkippedDirectoryPaths    = $skippedDirectoryPaths.ToArray()
            ByOwner                  = $byOwner.ToArray()
            Results                  = $rows
            Errors                   = $errors.ToArray()
        }
    }
}
