# Format-HelpMarkdown

*Renders parsed help data as a Markdown document.*

## DESCRIPTION

Emits sections in a stable order: the name as a level-one heading, the synopsis
in italics, then DESCRIPTION, PARAMETERS, EXAMPLES, INPUTS, OUTPUTS, NOTES, and
RELATED LINKS. Empty sections are omitted. Each example renders as a fenced
powershell block followed by its explanation.

## PARAMETERS

### -Name

The heading for the document, usually the function or script name.

### -Data

The parsed help data from ConvertFrom-CommentHelp.

## EXAMPLES

### Example 1

```powershell
$data = ConvertFrom-CommentHelp -Content (Get-Content -LiteralPath ./Public/Get-AclItem.ps1 -Raw)
Format-HelpMarkdown -Name 'Get-AclItem' -Data $data
```

Returns the help for Get-AclItem as Markdown.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.String. The rendered Markdown document.

