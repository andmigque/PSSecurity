using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Backup-FileParallel</h2>
####
function Backup-FileParallel {
    #### Mirror a directory tree to a destination as gzip files.
    ####
    #### The walk is recursive and the destination mirrors the source tree.
    #### Compression runs in parallel across files at `CompressionLevel.SmallestSize`.
    #### Per file failures are collected and written to `CompressionErrors.json`.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[string]`: __Path__
        ####     - *Existing source directory. Walked recursively.*
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,

        #### - `[string]`: __OutPath__
        ####     - *Destination root. Created when missing. Mirrors the source tree.*
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$OutPath,

        #### - `[int]`: __Throttle__
        ####     - *Throttle for `ForEach-Object -Parallel`. Defaults to 4.*
        [Parameter(Mandatory = $false)]
        [int]$Throttle = 4
    )

    # TODO: the parallel block needs a cleaner completion signal on termination.

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When `Path` does not exist.
    #### - When `Path` and `OutPath` are the same directory.
    $validDir = (Test-Path $Path -PathType Container)
    if (-not $validDir) { throw 'Path not found' }
    if ($Path -eq $OutPath) { throw 'Path can not equal OutPath' }
    if (-not (Test-Path $OutPath)) { New-Item $OutPath -ItemType Directory -Force }

    #### Both roots resolve to absolute paths before the parallel block starts.
    #### A relative path binds to each worker's own working directory, which is
    #### not guaranteed to match the caller's.
    $Path = Resolve-Path $Path
    $OutPath = Resolve-Path $OutPath

    #### Workers share one thread safe collection. `ConcurrentDictionary` holds the
    #### per file errors.
    $prlErr = [System.Collections.Concurrent.ConcurrentDictionary[string, string]]::new()

    Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object -Parallel {
        $errors = $using:prlErr

        $fPath = $_.FullName
        $relativePath = [System.IO.Path]::GetRelativePath($using:Path, $_.FullName)
        $destPath = Join-Path -Path $using:OutPath -ChildPath $relativePath
        $destDir = [System.IO.Path]::GetDirectoryName($destPath)

        if (-not (Test-Path -Path $destDir)) {
            [void](New-Item -Path $destDir -ItemType Directory -Force)
        }
        $gzipfPath = "${destPath}.gz"

        try {
            # Uses GZipStream at CompressionLevel.SmallestSize.
            $fileStream = [System.IO.File]::OpenRead($fPath)
            $gzipStream = [System.IO.File]::Create($gzipfPath)
            # Fully qualified because a parallel runspace does not inherit the
            # using namespace statements from the top of this file.
            $compressionLevel = [System.IO.Compression.CompressionLevel]::SmallestSize
            $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, $compressionLevel, $false)
            $fileStream.CopyTo($gzipWriter)
        }
        catch {
            # One bad file does not stop the mirror. The path and message are collected
            # and reported at the end instead.
            [void]($errors.TryAdd($fPath, $_.Exception.Message))
        }
        finally {
            if ($null -ne $gzipWriter) {
                $gzipWriter.Close()
            }

            if ($null -ne $fileStream) {
                $fileStream.Close()
            }
        }
    } -ThrottleLimit $Throttle

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - *Nothing on the success stream.*
    #### - *Writes one `.gz` per source file, mirroring the tree under `OutPath`.*
    #### - *Writes `CompressionErrors.json` under `OutPath` when any file failed,*
    ####   *and raises a warning naming that file.*
    if ($prlErr.Count -gt 0) {
        $errFilePath = Join-Path $OutPath 'CompressionErrors.json'
        $prlErr.GetEnumerator() |
            ConvertTo-Json -Depth 10 |
            Out-File -FilePath "$errFilePath"
        Write-Warning "See error details in $errFilePath"
    }
    else {
        Write-Information 'Compression complete'
    }
}
####
#### ---
####

