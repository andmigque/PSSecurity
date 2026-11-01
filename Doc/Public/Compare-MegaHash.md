# Compare-MegaHash

*Compares a directory tree with the joined hash saved by Join-MegaHash.*

## DESCRIPTION

Renames PSSecurity.hash in the module root to PSSecurity.hash.orig, replacing
an existing .orig file, then runs Join-MegaHash to write a new PSSecurity.hash
and compares the two files. Returns nothing when the tree is unchanged.

Run Join-MegaHash with the same -Path first.

## PARAMETERS

### -Path

The root directory to hash. Use the same path that was given to Join-MegaHash.

## EXAMPLES

### Example 1

```powershell
Join-MegaHash -Path .
Compare-MegaHash -Path .
```

Saves the joined hash of the current tree, then checks it again. Returns
nothing because nothing changed in between.

### Example 2

```powershell
if (Compare-MegaHash -Path .) { throw 'The module files have changed.' }
```

Stops when the tree no longer matches the saved hash.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. The Compare-Object differences
between the saved and the new joined hash. Nothing when they match.

