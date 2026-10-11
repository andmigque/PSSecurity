Set-StrictMode -Version Latest

function Compress-FileTree {
    <#
    .SYNOPSIS
        Compresses a directory tree into individual gzip files using thread jobs.

    .DESCRIPTION
        Discovers files beneath Path and mirrors their relative directories beneath
        OutPath. Each file is compressed separately using GZipStream and the
        SmallestSize compression level when available, or Optimal on .NET Framework.
        The complete original filename is retained:
        Config\Setting.psd1 becomes Config\Setting.psd1.gz.

        Up to Throttle reusable thread jobs consume a shared file queue. Discovery
        finishes before compression begins. The output directory is excluded from
        traversal, including when it is inside the source tree. Directory reparse
        points (such as junctions and symbolic links) are not traversed. Discovery
        uses Get-ChildItem without Force, so hidden items are omitted. Directory
        enumeration errors are suppressed and are not included in the file counts.

        Progress shows completed file attempts and a separate entry for each active
        worker, including its relative filename, source MiB processed, and percentage.
        Reading all source bytes is followed by archive finalization. Progress does
        not measure the compressed output size or compression ratio.

        Per-file compression errors are collected while other files continue. Normal
        completion returns one summary object. Source validation, job startup, and
        unhandled worker errors can terminate the invocation instead.

    .PARAMETER Path
        Existing source directory. Relative paths are resolved from the current
        location. The resolved source and output directories must be different.

    .PARAMETER OutPath
        Destination directory, created when missing. Relative source directories
        are preserved and .gz is appended to each filename. Existing destination
        archives with the same names are overwritten. Unrelated destination files
        are retained. Empty source directories do not produce destination folders.

    .PARAMETER Throttle
        Maximum number of compression workers, from 1 through 255. Defaults to 4.
        Fewer workers are started when there are fewer files. Each worker reuses a
        64 KiB buffer and processes multiple files rather than starting a job per file.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.Management.Automation.PSCustomObject
        One summary object with these properties:
        Path            - Resolved source directory.
        OutPath         - Resolved destination directory.
        TotalFiles      - Number of files discovered and queued.
        CompressedFiles - TotalFiles minus FailedFiles on normal completion.
        FailedFiles     - Number of source files with recorded compression errors.
        Errors          - Array of objects containing source Path and error Message.
        An empty source returns zero counts and an empty Errors array.

    .EXAMPLE
        Compress-FileTree -Path . -OutPath .\Generated

        Compresses the current tree into Generated, excluding Generated itself.

    .EXAMPLE
        $result = Compress-FileTree -Path C:\Documents -OutPath D:\Backup -Throttle 8
        $result.Errors | Format-Table Path, Message -Wrap

        Uses up to eight workers and inspects any per-file failures after completion.

    .EXAMPLE
        & {
            $ProgressPreference = 'SilentlyContinue'
            Compress-FileTree -Path .\Public -OutPath .\Generated\Public
        }

        Suppresses progress in a child scope while retaining the summary object.

    .NOTES
        Supports Windows PowerShell 5.1 and PowerShell 7. Start-ThreadJob is required.
        When Start-ThreadJob is unavailable, imports the ThreadJob module, installing
        it from PSGallery for the current user first if necessary. Installation
        requires network access and Install-Module. A missing NuGet package provider
        is also installed for the current user. Dependency failures terminate
        the invocation before compression begins.

        Ctrl+C signals cancellation and stops the invocation's jobs. Workers check
        cancellation between chunks, close streams, and remove incomplete archives
        they created. An individual synchronous read, write, or finalization must
        return before it can be interrupted. No completion summary is guaranteed
        after cancellation, and previously overwritten archives are not restored.

        This is a collection of per-file gzip streams, not a single tree archive.
        It does not preserve ACLs, timestamps, or other filesystem metadata, and
        does not provide a consistent snapshot of files changing during the run.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # Existing source directory to compress.
        [Parameter(Mandatory = $true, HelpMessage = 'Enter the existing source directory to compress.')]
        [string]$Path,

        # Destination directory for the mirrored gzip files; created when missing.
        [Parameter(Mandatory = $true, HelpMessage = 'Enter the destination directory for the gzip files.')]
        [string]$OutPath,

        # Maximum concurrent workers, from 1 through 255. Defaults to 4.
        [Parameter(Mandatory = $false, HelpMessage = 'Enter the maximum number of workers (1-255).')]
        [ValidateRange(1, 255)]
        [int]$Throttle = 4
    )

    if (-not (Get-Command Start-ThreadJob -ErrorAction SilentlyContinue)) {
        # Reuse the built-in command on PowerShell 7. Bootstrap the Gallery module
        # only when the command is unavailable, as on Windows PowerShell 5.1.
        if (-not (Get-Module -Name ThreadJob -ListAvailable)) {
            # Older PowerShellGet versions otherwise prompt to bootstrap NuGet.
            $nuget = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue |
                Where-Object { $_.Version -ge [version]'2.8.5.201' }
            if (-not $nuget) {
                [void](Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' `
                        -Scope CurrentUser -Force -Confirm:$false -ErrorAction Stop)
            }
            [void](Import-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -ErrorAction Stop)
            Install-Module -Name ThreadJob -Repository PSGallery -Scope CurrentUser `
                -AllowClobber -Force -Confirm:$false -ErrorAction Stop
        }
        Import-Module -Name ThreadJob -ErrorAction Stop
        [void](Get-Command Start-ThreadJob -ErrorAction Stop)
    }

    $validDir = (Test-Path $Path -PathType Container)
    if (-not $validDir) { throw 'Path not found' }
    if ($Path -eq $OutPath) { throw 'Path can not equal OutPath' }
    if (-not (Test-Path $OutPath)) { [void](New-Item $OutPath -ItemType Directory -Force) }

    # Normalize paths before comparing them so relative aliases and trailing
    # separators cannot bypass the source/output identity check.
    # .NET Framework has no TrimEndingDirectorySeparator. Keep filesystem roots
    # intact: trimming C:\ to C: would change an absolute path into a relative one.
    $Path = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
    $OutPath = (Resolve-Path -LiteralPath $OutPath -ErrorAction Stop).ProviderPath
    $separators = [char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $sourceRoot = [System.IO.Path]::GetPathRoot($Path)
    $outputRoot = [System.IO.Path]::GetPathRoot($OutPath)
    $Path = $Path.TrimEnd($separators)
    $OutPath = $OutPath.TrimEnd($separators)
    if ($Path.Length -lt $sourceRoot.Length) { $Path = $sourceRoot }
    if ($OutPath.Length -lt $outputRoot.Length) { $OutPath = $outputRoot }
    $pathComparison = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
        [StringComparison]::OrdinalIgnoreCase
    }
    else {
        [StringComparison]::Ordinal
    }
    if ($Path.Equals($OutPath, $pathComparison)) { throw 'Path can not equal OutPath' }

    # Thread jobs share these objects by reference. Concurrent collections protect
    # cross-thread reads/writes; each processed counter has only one writer.
    $prlErr = [System.Collections.Concurrent.ConcurrentDictionary[string, string]]::new()
    $cancellation = [System.Threading.CancellationTokenSource]::new()
    $files = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
    $processed = [System.Collections.Concurrent.ConcurrentDictionary[int, int]]::new()
    # Immutable snapshots contain relative filename, bytes consumed, and source
    # length. Replacing a snapshot keeps its three fields consistent for readers.
    $fileProgress = [System.Collections.Concurrent.ConcurrentDictionary[int, System.Tuple[string, long, long]]]::new()

    $compressFile = {
        param($files, $sourcePath, $outputPath, $errors, $cancellation, $processed, $workerId, $fileProgress)

        # Allocate once per worker, not per file. Cache directories locally to avoid
        # repeated filesystem calls for siblings; CreateDirectory tolerates races.
        $buffer = [byte[]]::new(64KB)
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
        if ([Enum]::IsDefined([System.IO.Compression.CompressionLevel], 'SmallestSize')) {
            $compressionLevel = [System.IO.Compression.CompressionLevel]::SmallestSize
        }
        # Every queued file was discovered below sourcePath. Remove its directory
        # prefix instead of calling GetRelativePath, which .NET Framework lacks.
        $sourcePrefix = $sourcePath.TrimEnd([char[]]@(
                [System.IO.Path]::DirectorySeparatorChar,
                [System.IO.Path]::AltDirectorySeparatorChar
            )) + [System.IO.Path]::DirectorySeparatorChar
        $createdDirectories = [System.Collections.Generic.HashSet[string]]::new()
        $fPath = $null
        $processed[$workerId] = 0
        $updateTimer = [System.Diagnostics.Stopwatch]::StartNew()
        # TryDequeue claims each file for exactly one worker without a separate lock.
        while (-not $cancellation.IsCancellationRequested -and $files.TryDequeue([ref]$fPath)) {
            $fileStream = $null
            $gzipStream = $null
            $gzipWriter = $null
            $completed = $false

            try {
                if ($cancellation.IsCancellationRequested) { return }
                $relativePath = $fPath.Substring($sourcePrefix.Length)
                $destPath = [System.IO.Path]::Combine($outputPath, $relativePath)
                $destDir = [System.IO.Path]::GetDirectoryName($destPath)

                if (-not $createdDirectories.Contains($destDir)) {
                    [void][System.IO.Directory]::CreateDirectory($destDir)
                    [void]$createdDirectories.Add($destDir)
                }
                $gzipfPath = "${destPath}.gz"

                $fileStream = [System.IO.File]::OpenRead($fPath)
                $fileLength = $fileStream.Length
                $fileProgress[$workerId] = [System.Tuple[string, long, long]]::new($relativePath, 0, $fileLength)
                $updateTimer.Restart()
                $gzipStream = [System.IO.File]::Create($gzipfPath)
                $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, $compressionLevel, $false)
                # Chunked copying provides cancellation checkpoints. Publish at most
                # five intermediate snapshots per second to keep progress inexpensive.
                while (-not $cancellation.IsCancellationRequested) {
                    $bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)
                    if ($bytesRead -eq 0) { break }
                    if ($cancellation.IsCancellationRequested) { break }
                    $gzipWriter.Write($buffer, 0, $bytesRead)
                    if ($updateTimer.ElapsedMilliseconds -ge 200) {
                        $fileProgress[$workerId] = [System.Tuple[string, long, long]]::new($relativePath, $fileStream.Position, $fileLength)
                        $updateTimer.Restart()
                    }
                }
                $fileProgress[$workerId] = [System.Tuple[string, long, long]]::new($relativePath, $fileStream.Position, $fileLength)
                # Disposal writes the gzip trailer; consuming the source alone does
                # not mean the archive has been successfully finalized.
                $gzipWriter.Dispose()
                $gzipWriter = $null
                $completed = -not $cancellation.IsCancellationRequested
            }
            catch {
                # Record this file's failure without abandoning the remaining queue.
                [void]$errors.TryAdd($fPath, $_.Exception.Message)
            }
            finally {
                # Always release file handles, even if gzip disposal fails. Use a
                # direct delete so cleanup can run in a stopped worker pipeline.
                try {
                    if ($null -ne $gzipWriter) { $gzipWriter.Dispose() }
                }
                finally {
                    if ($null -ne $gzipStream) { $gzipStream.Dispose() }
                    if ($null -ne $fileStream) { $fileStream.Dispose() }
                    if (-not $completed -and $null -ne $gzipStream) {
                        [System.IO.File]::Delete($gzipfPath)
                    }
                }
                # Processed includes successful and failed attempts. Clear the file
                # snapshot so a worker's previous filename cannot linger in progress.
                $processed[$workerId]++
                $removedProgress = $null
                [void]$fileProgress.TryRemove($workerId, [ref]$removedProgress)
            }
        }
    }

    $jobs = [System.Collections.Generic.List[System.Management.Automation.Job]]::new()
    try {
        Write-Progress -Activity 'Compressing file tree' -Status 'Discovering files' -PercentComplete -1
        $progressTimer = [System.Diagnostics.Stopwatch]::StartNew()
        # Walk directories explicitly: pruning OutPath before descent prevents
        # reading old backups or following a recursively growing output tree.
        $directories = [System.Collections.Generic.Stack[string]]::new()
        $directories.Push($Path)
        while ($directories.Count -gt 0) {
            foreach ($item in Get-ChildItem -LiteralPath $directories.Pop() -ErrorAction SilentlyContinue) {
                if ($item.PSIsContainer) {
                    if (-not $item.FullName.Equals($OutPath, $pathComparison) -and
                        -not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                        $directories.Push($item.FullName)
                    }
                }
                else {
                    $files.Enqueue($item.FullName)
                }
                if ($progressTimer.ElapsedMilliseconds -ge 200) {
                    Write-Progress -Activity 'Compressing file tree' -Status "$($files.Count) files discovered" -PercentComplete -1
                    $progressTimer.Restart()
                }
            }
        }

        # Freeze the denominator before workers drain the queue. Job count now
        # represents workers, so it must never be used as the file count.
        $totalFiles = $files.Count
        $workerCount = [Math]::Min($Throttle, $totalFiles)
        for ($workerId = 0; $workerId -lt $workerCount; $workerId++) {
            $job = Start-ThreadJob -ScriptBlock $compressFile -ThrottleLimit $Throttle -ErrorAction Stop `
                -ArgumentList $files, $Path, $OutPath, $prlErr, $cancellation, $processed, $workerId, $fileProgress
            $jobs.Add($job)
        }

        if ($jobs.Count -gt 0) {
            do {
                $finished = 0
                foreach ($count in $processed.Values) { $finished += $count }
                # Exit based on terminal job states, not counters: an unhandled
                # worker failure must reach Receive-Job rather than strand this loop.
                $active = $false
                foreach ($job in $jobs) {
                    if ($job.State -notin 'Completed', 'Failed', 'Stopped') { $active = $true; break }
                }
                # Floor avoids displaying 100% while the final file is still active.
                $percentComplete = [int][Math]::Floor(100 * $finished / $totalFiles)
                Write-Progress -Activity 'Compressing file tree' `
                    -Status "$finished of $totalFiles files processed; $($prlErr.Count) errors" `
                    -PercentComplete $percentComplete

                # Only the caller renders progress. ID 0 is the overall operation;
                # worker IDs start at 1 and are cleared when their file completes.
                for ($workerId = 0; $workerId -lt $workerCount; $workerId++) {
                    $snapshot = $null
                    if ($fileProgress.TryGetValue($workerId, [ref]$snapshot)) {
                        $filePercent = if ($snapshot.Item3 -gt 0) {
                            [int][Math]::Min(100, [Math]::Floor(100 * $snapshot.Item2 / $snapshot.Item3))
                        }
                        else { 100 }
                        $byteStatus = '{0:N1} / {1:N1} MiB ({2}%)' -f ($snapshot.Item2 / 1MB), ($snapshot.Item3 / 1MB), $filePercent
                        if ($snapshot.Item2 -ge $snapshot.Item3) { $byteStatus += ' - finalizing archive' }
                        Write-Progress -Id ($workerId + 1) -ParentId 0 -Activity $snapshot.Item1 `
                            -Status $byteStatus -PercentComplete $filePercent
                    }
                    else {
                        Write-Progress -Id ($workerId + 1) -Activity 'Compressing file' -Completed
                    }
                }

                if ($active) {
                    Start-Sleep -Milliseconds 200
                }
            } while ($active)

            # Surface worker errors before returning a success-style summary.
            $jobs | Receive-Job -Wait -ErrorAction Stop
        }
    }
    finally {
        # Signal cooperative cancellation before explicitly stopping jobs. Limit
        # cleanup to jobs owned by this invocation and clear every progress entry.
        $cancellation.Cancel()
        for ($workerId = 0; $workerId -lt $jobs.Count; $workerId++) {
            Write-Progress -Id ($workerId + 1) -Activity 'Compressing file' -Completed
        }
        Write-Progress -Activity 'Compressing file tree' -Completed
        if ($jobs.Count -gt 0) {
            $jobs | Stop-Job
            $jobs | Remove-Job
        }
        $cancellation.Dispose()
    }

    # Keep operational progress out of the success stream: return one result only.
    [pscustomobject]@{
        Path            = $Path
        OutPath         = $OutPath
        TotalFiles      = $totalFiles
        CompressedFiles = $totalFiles - $prlErr.Count
        FailedFiles     = $prlErr.Count
        Errors          = @(foreach ($errorEntry in $prlErr.GetEnumerator()) {
                [pscustomobject]@{
                    Path    = $errorEntry.Key
                    Message = $errorEntry.Value
                }
            })
    }
}

