# Get-FileMultiThreaded

*Recursively returns the files under a directory that match a name pattern,*
*walking its subdirectories in parallel.*

## DESCRIPTION

Lists the files directly in -Directory, then walks each of its subdirectories
recursively with Get-FileSingleThreaded, -ThrottleLimit subdirectories at a
time, using Invoke-ParallelJob.

Directories whose name is in -Exclude are skipped entirely, so their contents
are never read. Directories that cannot be read are skipped instead of stopping
the walk. Symbolic links and junctions are not followed. Hidden and system
items are included. Name matching is case insensitive on every platform.

Files are returned as workers find them, not in directory order.

## PARAMETERS

### -Directory

The directory to walk. Accepts directories from the pipeline.

### -Include

File name patterns to return, such as *.ps1. A file is returned when its name
matches any pattern.

### -Exclude

Directory names to skip, such as .git or node_modules. Matched against the
directory name only, not its path.

### -ThrottleLimit

The number of subdirectories walked at once, from 1 through 255. Defaults to
75% of the processors, rounded down, and at least 1.

## EXAMPLES

### Example 1

```powershell
Get-FileMultiThreaded -Directory $HOME/Develop -Include '*.ps1', '*.psm1' -Exclude '.git', 'node_modules'
```

Returns every PowerShell script under ~/Develop, skipping .git and node_modules.

### Example 2

```powershell
Get-Item -LiteralPath /etc | Get-FileMultiThreaded -Include '*.conf' -Exclude 'ssl' -ThrottleLimit 2
```

Returns the .conf files under /etc, two subdirectories at a time, skipping any
directory named ssl and any directory the current user cannot read.

## INPUTS

System.IO.DirectoryInfo. You can pipe directories to this function.

## OUTPUTS

System.IO.FileInfo. One object for each matching file.

