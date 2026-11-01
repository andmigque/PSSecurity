# Join-MegaHash

*Joins the hashes of a directory tree into one file.*

## DESCRIPTION

Hashes the directory tree with Write-DirectoryHash, joins every hash into one
string, and writes it to PSSecurity.hash in the module root. An existing
PSSecurity.hash is overwritten. Use Compare-MegaHash to check whether the tree
has changed since.

The hashes are joined in the order Write-DirectoryHash returns them.

## PARAMETERS

### -Path

The root directory to hash.

## EXAMPLES

### Example 1

```powershell
Join-MegaHash -Path .
```

Writes the joined hash of the current directory tree to PSSecurity.hash.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.String. The path of PSSecurity.hash.

