Set-StrictMode -Version Latest

function Format-HelpMarkdown {
    <#
    .SYNOPSIS
        Renders parsed help data as a Markdown document.

    .DESCRIPTION
        Emits sections in a stable order: the name as a level-one heading, the synopsis
        in italics, then DESCRIPTION, PARAMETERS, EXAMPLES, INPUTS, OUTPUTS, NOTES, and
        RELATED LINKS. Empty sections are omitted. Each example renders as a fenced
        powershell block followed by its explanation.

    .PARAMETER Name
        Heading for the document, usually the function or script name.

    .PARAMETER Data
        Parsed help data from ConvertFrom-CommentHelp.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.String. The rendered Markdown document.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Heading for the document, usually the function or script name.
        [Parameter(Mandatory = $true, HelpMessage = 'Enter the heading for the document.')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Parsed help data from ConvertFrom-CommentHelp.
        [Parameter(Mandatory = $true, HelpMessage = 'Enter the parsed help data to render.')]
        [pscustomobject]$Data
    )

    $out = [System.Collections.Generic.List[string]]::new()
    $out.Add("# $Name")
    $out.Add('')

    if ($Data.Synopsis) {
        foreach ($line in ($Data.Synopsis -split "`n")) {
            $out.Add("*$line*")
        }
        $out.Add('')
    }

    if ($Data.Description) {
        $out.Add('## DESCRIPTION')
        $out.Add('')
        $out.Add($Data.Description)
        $out.Add('')
    }

    if ($Data.Parameters.Count -gt 0) {
        $out.Add('## PARAMETERS')
        $out.Add('')
        foreach ($parameter in $Data.Parameters) {
            $out.Add("### -$($parameter.Name)")
            $out.Add('')
            $out.Add($parameter.Text)
            $out.Add('')
        }
    }

    if ($Data.Examples.Count -gt 0) {
        $out.Add('## EXAMPLES')
        $out.Add('')
        $exampleNumber = 0
        foreach ($example in $Data.Examples) {
            $exampleNumber++
            $out.Add("### Example $exampleNumber")
            $out.Add('')
            if ($example.Code) {
                $out.Add('```powershell')
                $out.Add($example.Code)
                $out.Add('```')
                $out.Add('')
            }
            if ($example.Text) {
                $out.Add($example.Text)
                $out.Add('')
            }
        }
    }

    if ($Data.Inputs) {
        $out.Add('## INPUTS')
        $out.Add('')
        $out.Add($Data.Inputs)
        $out.Add('')
    }

    if ($Data.Outputs) {
        $out.Add('## OUTPUTS')
        $out.Add('')
        $out.Add($Data.Outputs)
        $out.Add('')
    }

    if ($Data.Notes) {
        $out.Add('## NOTES')
        $out.Add('')
        $out.Add($Data.Notes)
        $out.Add('')
    }

    if ($Data.Links.Count -gt 0) {
        $out.Add('## RELATED LINKS')
        $out.Add('')
        foreach ($link in $Data.Links) {
            $out.Add("- $link")
        }
        $out.Add('')
    }

    return ($out -join "`n")
}
