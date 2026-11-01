# Write-DirectoryHash

*Hashes the files in a directory tree using the module's hash settings.*

## DESCRIPTION

Lists the files in the tree with Get-Tree on multiple threads and hashes each
file with Get-FileHash. The file name patterns to include, the directory names to
exclude, and the hash algorithm come from HashIndexInclude, HashIndexExclude,
and HashIndexAlgorithm in Config/Setting.psd1.

Each path is returned relative to the directory, with the home directory
removed, so the output can be shared without revealing the user name.

## PARAMETERS

### -Path

The root directory to hash. Wildcards are accepted. Accepts paths from the
pipeline.

## EXAMPLES

### Example 1

```powershell
Write-DirectoryHash -Path .
```

Hashes the files in the current directory tree.

### Example 2

```powershell
Write-DirectoryHash -Path ./Public | Sort-Object -Property Path | Export-Csv -LiteralPath ./PublicHash.csv
```

Saves a sorted list of the hashes of the public functions.

### Example 3

```powershell
'./Public', './Private' | Write-DirectoryHash
```

Hashes the files in both directories.

## INPUTS

System.String. You can pipe directory paths to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object per file with its
relative Path and Hash.

