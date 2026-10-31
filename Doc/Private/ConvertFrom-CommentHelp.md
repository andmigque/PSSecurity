# ConvertFrom-CommentHelp

*Parses the comment-based help of a script into data.*

## DESCRIPTION

Finds the first comment block containing a help keyword and parses it into an
ordered structure. Found is true only when such a block exists; every other
field is an empty string or an empty array when absent, so the result never
contains null. Recognized keywords are SYNOPSIS, DESCRIPTION, PARAMETER,
EXAMPLE, INPUTS, OUTPUTS, NOTES, and LINK. Within an example, the first blank
line ends the code and starts the explanation, and the code is dedented by the
keyword indent plus four spaces.

## PARAMETERS

### -Content

The raw text of the script to parse.

## EXAMPLES

### Example 1

```powershell
$data = ConvertFrom-CommentHelp -Content (Get-Content -LiteralPath ./Public/Get-AclItem.ps1 -Raw)
$data.Parameters | Format-Table Name, Text
```

Lists the documented parameters of Get-AclItem.

## INPUTS

None. This function does not accept pipeline input.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object with Found, Synopsis,
Description, Inputs, Outputs, Notes, Links, Parameters, and Examples.
Parameters contains Name and Text; Examples contains Code and Text.

