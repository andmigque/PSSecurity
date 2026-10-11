if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Get-SuidBinary {
        <#
    .SYNOPSIS
        Finds SUID and SGID binaries on Linux.

    .DESCRIPTION
        Returns one report describing executables on the scan roots whose SUID (setuid) or
        SGID (setgid) mode bits are set, and flags the ones outside the configured known-good
        list. The roots are walked with an explicit directory stack, matching the module's
        Compress-FileTree traversal. Symlinks are skipped and mount points parsed from
        /proc/mounts are not traversed, so the scan stays on the filesystems of its roots and
        pseudo filesystems such as /proc are excluded; a mount can still be scanned by passing
        it as a root. Excluded paths are not traversed at all.

        SUID and SGID are the bits that let a process escalate to the owner or group of the
        binary, so an unexpected one is a common persistence or privilege-escalation vector.
        Each finding is marked KnownGood only when its path matches an entry in the module's
        SuidKnownGoodPath setting; everything else is Flagged. The known-good list is
        deliberately conservative so unfamiliar binaries surface for review. ReviewFiles
        holds the flagged subset and ByOwner groups all findings by owning account.

        The report is one object carrying coverage counters and an AuditStatus, so a scan with
        no findings is never mistaken for a clean or complete result. A non-root session cannot
        enumerate root-only directories, so those are skipped with verbose notes and counted at
        the end. Pass -Elevate to re-run the scan as root through sudo for a complete report.

    .PARAMETER Path
        Root directories to scan. Defaults to the module's SuidIncludePath setting from
        Config/Setting.psd1.

    .PARAMETER ExcludePath
        Path patterns to skip. Wildcards are allowed and matching directories are not traversed.
        Defaults to the module's SuidExcludePath setting; passing this parameter replaces the
        default list, so @() disables all exclusions.

    .PARAMETER KnownGoodPath
        Path patterns treated as known-good SUID/SGID binaries. Wildcards are allowed. Findings
        matching any pattern are marked KnownGood; all others are Flagged. Defaults to the
        module's SuidKnownGoodPath setting; passing this parameter replaces the default list.

    .PARAMETER Elevate
        Re-runs the audit as root through sudo when the current session is not root, so
        root-only directories are enumerated and the report can be Complete. sudo may prompt
        for a password. Ignored when the session is already root.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject with AuditStatus, ScannedRoots, KnownGoodPaths, ExcludedPatterns,
        ScannedFiles, ScannedDirectories, TotalFiles, SetuidFiles, SetgidFiles, KnownGoodFiles,
        FlaggedFiles, SkippedDirectories, SkippedDirectoryPaths, ByOwner, ReviewFiles, Results,
        and Errors. Results contains the individual findings with Path, Setuid, Setgid, Mode,
        Owner, SizeBytes, LastWriteTime, and KnownGood; Owner is Unknown when it cannot be
        read. ReviewFiles contains the flagged findings only. Errors contains Path and Message
        for enumeration failures. An empty scan returns zero counts and empty arrays.

    .EXAMPLE
        $report = Get-SuidBinary
        $report.ReviewFiles | Format-Table Path, Mode, Owner

        Audits the whole root filesystem and lists only the binaries outside the known-good list.

    .EXAMPLE
        $report = Get-SuidBinary -Path /usr, /opt -Elevate
        $report.ByOwner

        Audits the binary trees as root and reviews which accounts own the SUID/SGID findings.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. Requires PowerShell
        7.4 for File.GetUnixFileMode. Default scan roots, exclusions, and the known-good list
        come from the SuidIncludePath, SuidExcludePath, and SuidKnownGoodPath keys in
        Config/Setting.psd1, so the allowlist is data you can tune per distribution. Owner names
        come from one batched GNU stat call per chunk of findings. A non-root audit skips
        directories it cannot enumerate with verbose notes and reports the skipped count as a
        single warning at the end; other failures are collected in Errors. A full root scan
        reads every file's metadata and can take a while on large filesystems.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            # Root directories to scan. Defaults to the module's SuidIncludePath setting.
            [Parameter(HelpMessage = 'Enter the root directories to scan. Defaults to the SuidIncludePath setting.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$Path = $script:SuidIncludePath,

            # Path patterns to skip. Defaults to the module's SuidExcludePath setting.
            [Parameter(HelpMessage = 'Enter path patterns to exclude. Defaults to the SuidExcludePath setting.')]
            [string[]]$ExcludePath = $script:SuidExcludePath,

            # Path patterns treated as known-good SUID/SGID binaries.
            [Parameter(HelpMessage = 'Enter known-good SUID/SGID path patterns. Defaults to the SuidKnownGoodPath setting.')]
            [string[]]$KnownGoodPath = $script:SuidKnownGoodPath,

            # Re-run the audit as root through sudo when the current session is not root.
            [Parameter(HelpMessage = 'Re-run the audit as root through sudo for a complete scan.')]
            [switch]$Elevate
        )

        $sessionIsRoot = (& id -u) -eq 0

        if ($Elevate -and -not $sessionIsRoot) {
            # Array parameters bind as one comma-separated value (PowerShell rejects a
            # repeated parameter), so rebuild the invocation for the sudo child process.
            $pathArg = ($Path | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','
            $call = "Get-SuidBinary -Path $pathArg"

            if ($ExcludePath.Count -eq 0) {
                $call += ' -ExcludePath @()'
            }
            else {
                $excludeArg = ($ExcludePath | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','
                $call += " -ExcludePath $excludeArg"
            }

            if ($KnownGoodPath.Count -eq 0) {
                $call += ' -KnownGoodPath @()'
            }
            else {
                $knownGoodArg = ($KnownGoodPath | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','
                $call += " -KnownGoodPath $knownGoodArg"
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
                        continue
                    }

                    $unixMode = [System.IO.File]::GetUnixFileMode($entry.FullName)
                    $scannedFiles++
                    $isSetuid = [bool]($unixMode -band [System.IO.UnixFileMode]::SetUser)
                    $isSetgid = [bool]($unixMode -band [System.IO.UnixFileMode]::SetGroup)

                    if (-not $isSetuid -and -not $isSetgid) {
                        continue
                    }

                    $knownGood = $false
                    foreach ($pattern in $KnownGoodPath) {
                        if ($entry.FullName -like $pattern) {
                            $knownGood = $true
                            break
                        }
                    }

                    $record = [PSCustomObject]@{
                        Path          = $entry.FullName
                        Setuid        = $isSetuid
                        Setgid        = $isSetgid
                        Mode          = [Convert]::ToString([int]$unixMode, 8)
                        Owner         = 'Unknown'
                        SizeBytes     = $entry.Length
                        LastWriteTime = $entry.LastWriteTime
                        KnownGood     = $knownGood
                    }

                    $records.Add($record)
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

        $reviewFiles = @($rows | Where-Object { -not $_.KnownGood })

        [pscustomobject]@{
            AuditStatus           = $auditStatus
            ScannedRoots          = $scanRoots
            KnownGoodPaths        = $KnownGoodPath
            ExcludedPatterns      = $ExcludePath
            ScannedFiles          = $scannedFiles
            ScannedDirectories    = $scannedDirectories
            TotalFiles            = $rows.Count
            SetuidFiles           = @($rows | Where-Object { $_.Setuid }).Count
            SetgidFiles           = @($rows | Where-Object { $_.Setgid }).Count
            KnownGoodFiles        = @($rows | Where-Object { $_.KnownGood }).Count
            FlaggedFiles          = $reviewFiles.Count
            SkippedDirectories    = $skippedDirectoryCount
            SkippedDirectoryPaths = $skippedDirectoryPaths.ToArray()
            ByOwner               = $byOwner.ToArray()
            ReviewFiles           = $reviewFiles
            Results               = $rows
            Errors                = $errors.ToArray()
        }
    }
}
