# Search-PatternInFile

*Searches the files under a path for a regular expression.*

## DESCRIPTION

Recurses the path, including hidden and system files, and searches each file
with Select-String on parallel threads. Files are read as UTF-8 and every match
on a line is returned. Files and directories that can't be read are skipped.

When -Pattern is not given, searches for IPv4 addresses.

## PARAMETERS

### -Path

The file or directory to search. Wildcards are accepted. Defaults to the
current location. Accepts paths from the pipeline.

### -Pattern

The regular expression to search for. Defaults to a pattern that matches IPv4
addresses.

### -ThrottleLimit

The maximum number of files searched at once, from 1 through 255. Defaults to
75% of the processors, rounded down, and at least 1.

## EXAMPLES

### Example 1

```powershell
Search-PatternInFile -Path ./Doc/PwshBestPractice/PowershellExamples.md -Pattern 'Get-FileHash'
```

Finds the Microsoft help examples that use Get-FileHash.

### Example 2

```powershell
Search-PatternInFile -Path ./Config
```

Finds the IPv4 addresses in every file under ./Config.

### Example 3

```powershell
'./Public', './Private' | Search-PatternInFile -Pattern 'using namespace' | Select-Object -ExpandProperty Path
```

Lists the files in Public and Private that still have a using namespace line.

## INPUTS

System.String. You can pipe paths to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object per file with at least
one match, with the file path, the match count, and the line number, line, and
matched values of each match.

