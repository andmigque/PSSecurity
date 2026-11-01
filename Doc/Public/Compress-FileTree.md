# Compress-FileTree

*Compresses a directory tree into individual gzip files using thread jobs.*

## DESCRIPTION

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

## PARAMETERS

### -Path

Existing source directory. Relative paths are resolved from the current
location. The resolved source and output directories must be different.

### -OutPath

Destination directory, created when missing. Relative source directories
are preserved and .gz is appended to each filename. Existing destination
archives with the same names are overwritten. Unrelated destination files
are retained. Empty source directories do not produce destination folders.

### -Throttle

Maximum number of compression workers, from 1 through 255. Defaults to 4.
Fewer workers are started when there are fewer files. Each worker reuses a
64 KiB buffer and processes multiple files rather than starting a job per file.

## EXAMPLES

### Example 1

```powershell
Compress-FileTree -Path . -OutPath .\Generated
```

Compresses the current tree into Generated, excluding Generated itself.

### Example 2

```powershell
$result = Compress-FileTree -Path C:\Documents -OutPath D:\Backup -Throttle 8
$result.Errors | Format-Table Path, Message -Wrap
```

Uses up to eight workers and inspects any per-file failures after completion.

### Example 3

```powershell
& {
    $ProgressPreference = 'SilentlyContinue'
    Compress-FileTree -Path .\Public -OutPath .\Generated\Public
}
```

Suppresses progress in a child scope while retaining the summary object.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.Management.Automation.PSCustomObject
One summary object with these properties:
Path            - Resolved source directory.
OutPath         - Resolved destination directory.
TotalFiles      - Number of files discovered and queued.
CompressedFiles - TotalFiles minus FailedFiles on normal completion.
FailedFiles     - Number of source files with recorded compression errors.
Errors          - Array of objects containing source Path and error Message.
An empty source returns zero counts and an empty Errors array.

## NOTES

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

