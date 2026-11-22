# Get-EnumeratedDirectory

*Lists the child directories of a filesystem path.*

## DESCRIPTION

Returns immediate child directories by default. With -Recurse, a matching
exclusion skips the entire subtree. The walk includes hidden directories,
skips reparse points such as symbolic links, and skips unreadable contents.

## PARAMETERS

### -LiteralPath

Directory to enumerate. The path is used exactly as typed, including brackets.
Defaults to the current location. Accepts directory paths from the pipeline.

### -Exclude

Case-insensitive patterns matched against each directory name. Use * for
any number of characters and ? for one character. Brackets are literal.

### -Recurse

Searches all descendants of the starting directory.

## EXAMPLES

### Example 1

```powershell
Get-EnumeratedDirectory
```

Lists the immediate child directories of the current location.

### Example 2

```powershell
Get-EnumeratedDirectory -LiteralPath . -Recurse -Exclude '.git', 'bin*'
```

Lists descendants and skips subtrees named .git or starting with bin.

### Example 3

```powershell
'./Public', './Private' | Get-EnumeratedDirectory -Recurse
```

Returns a separate list of descendants for each input path.

## INPUTS

System.String. You can pipe directory paths to this function.

## OUTPUTS

System.Collections.Generic.List[System.IO.DirectoryInfo]. One list per
input path. A directory with no matching children produces an empty list.

## NOTES

**Restart PowerShell after changing the embedded directory enumerator type.**
The first enumeration in the new session compiles the updated definition.

