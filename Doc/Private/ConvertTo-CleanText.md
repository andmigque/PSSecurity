# ConvertTo-CleanText

*Joins text lines and strips leading and trailing blank lines.*

## DESCRIPTION

Joins the lines with newlines after removing blank or whitespace-only lines from
the start and end. Blank lines in the middle are kept. Used by
ConvertFrom-CommentHelp to tidy each help section.

## PARAMETERS

### -Text

The lines to join. May be null or empty, because help sections are often empty.

## EXAMPLES

### Example 1

```powershell
$lines = [System.Collections.Generic.List[string]]@('', 'First line', '', 'Last line', '  ')
ConvertTo-CleanText -Text $lines
```

Returns "First line`n`nLast line".

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.String. The joined text, or an empty string when there is no content.

