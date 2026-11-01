# Convert-CommentHelpToMarkdown

*Converts PowerShell comment-based help into Markdown documents.*

## DESCRIPTION

Reads script files, extracts each comment-based help block, and writes one
Markdown document per script. Sections are emitted in a stable order:

- FUNCTION
- .SYNOPSIS
- .DESCRIPTION
- .PARAMETERS
- .EXAMPLES
- .INPUTS
- .OUTPUTS
- .NOTES
- .RELATED LINKS

Empty sections are omitted. Each example renders as a fenced powershell code
block followed by its explanation, and the code is dedented by the keyword
indent plus four spaces so the block reads as runnable PowerShell.

Only .ps1 files are processed. A directory under Path is searched recursively,
so -Path .\ collects every script in the tree. Wildcards are also supported,
for example .\Public\*.ps1.

The parser recognizes the common help keywords: SYNOPSIS, DESCRIPTION,
PARAMETER, EXAMPLE, INPUTS, OUTPUTS, NOTES, and LINK. A script without a
recognizable help block is reported in Errors instead of being skipped
silently, so a documentation run over a whole tree shows exactly which files
still need help written. Each generated document overwrites an existing .md
file with the same name.

Returns one summary object with counts, per-file Results, and Errors, matching
the module's Compress-FileTree report shape. A request that matches no scripts
terminates with an error.

## PARAMETERS

### -Path

Script files or directories to convert. Directories are searched recursively
and wildcards are supported, for example .\Public\*.ps1. Only .ps1 files are
processed.

### -OutPath

Directory for the generated .md files, created when missing. When omitted,
each file is written beside its source. Existing documents with the same name
are overwritten.

## EXAMPLES

### Example 1

```powershell
Convert-CommentHelpToMarkdown -Path .\Public\Get-AclItem.ps1
```

Writes Get-AclItem.md next to the source file.

### Example 2

```powershell
$report = Convert-CommentHelpToMarkdown -Path .\Public\*.ps1 -OutPath .\Doc\Public
$report.Results | Format-Table Path, OutputPath
```

Generates one Markdown file per public function under .\Doc\Public and inspects
the per-file records.

### Example 3

```powershell
$report = Convert-CommentHelpToMarkdown -Path .\
$report.Errors | Format-Table Path, Message
```

Recurses the current tree for .ps1 files and lists the scripts that still need
help written.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object with TotalFiles,
ConvertedFiles, FailedFiles, Results, and Errors. Results contains Path and
OutputPath for every document that was written. Errors contains Path and
Message for files with no comment-based help and for conversion or write
failures. ConvertedFiles plus FailedFiles equals TotalFiles.

## NOTES

Output names come from the function declaration inside the script when one is
present, and from the file name otherwise, so a help block that documents a
single function is headed under that function's name. Files are read with -Raw
and written as UTF-8.

