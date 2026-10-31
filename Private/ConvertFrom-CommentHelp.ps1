#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function ConvertFrom-CommentHelp {
    <#
    .SYNOPSIS
        Parses the comment-based help of a script into data.

    .DESCRIPTION
        Finds the first comment block containing a help keyword and parses it into an
        ordered structure. Found is true only when such a block exists; every other
        field is an empty string or an empty array when absent, so the result never
        contains null. Recognized keywords are SYNOPSIS, DESCRIPTION, PARAMETER,
        EXAMPLE, INPUTS, OUTPUTS, NOTES, and LINK. Within an example, the first blank
        line ends the code and starts the explanation, and the code is dedented by the
        keyword indent plus four spaces.

    .PARAMETER Content
        The raw text of the script to parse.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. One object with Found, Synopsis,
        Description, Inputs, Outputs, Notes, Links, Parameters, and Examples.
        Parameters contains Name and Text; Examples contains Code and Text.

    .EXAMPLE
        $data = ConvertFrom-CommentHelp -Content (Get-Content -LiteralPath ./Public/Get-AclItem.ps1 -Raw)
        $data.Parameters | Format-Table Name, Text

        Lists the documented parameters of Get-AclItem.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, HelpMessage = 'Enter the raw script text to parse.')]
        [ValidateNotNullOrEmpty()]
        [string]$Content
    )

    $keywords = 'SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE|INPUTS|OUTPUTS|NOTES|LINK'
    $keywordPattern = [regex]"^\s*\.(?<keyword>$keywords)(?:\s+(?<argument>.*))?$"

    # The first comment block containing a help keyword is the help block.
    $block = [regex]::Matches($Content, '(?s)<#(?<body>.*?)#>') |
        Where-Object { $_.Groups['body'].Value -match "(?m)^\s*\.($keywords)\b" } |
        Select-Object -First 1

    $lines = @(if ($block) { $block.Groups['body'].Value -split "`r?`n" })

    $synopsis = [System.Collections.Generic.List[string]]::new()
    $description = [System.Collections.Generic.List[string]]::new()
    $inputs = [System.Collections.Generic.List[string]]::new()
    $outputs = [System.Collections.Generic.List[string]]::new()
    $notes = [System.Collections.Generic.List[string]]::new()
    $links = [System.Collections.Generic.List[string]]::new()
    $parameters = [System.Collections.Generic.List[object]]::new()
    $examples = [System.Collections.Generic.List[object]]::new()

    # Lines outside a recognized section, such as after .LINK, collect here unused.
    $ignored = [System.Collections.Generic.List[string]]::new()

    $current = $ignored
    $inExampleCode = $false
    $exampleIndent = 0

    foreach ($line in $lines) {
        $keywordMatch = $keywordPattern.Match($line)
        if ($keywordMatch.Success) {
            $keyword = $keywordMatch.Groups['keyword'].Value.ToUpperInvariant()
            $argument = $keywordMatch.Groups['argument'].Value
            $inExampleCode = $false

            switch ($keyword) {
                'SYNOPSIS' {
                    $current = $synopsis
                }
                'DESCRIPTION' {
                    $current = $description
                }
                'INPUTS' {
                    $current = $inputs
                }
                'OUTPUTS' {
                    $current = $outputs
                }
                'NOTES' {
                    $current = $notes
                }
                'PARAMETER' {
                    $parameter = [ordered]@{
                        Name = $argument.Trim()
                        Text = [System.Collections.Generic.List[string]]::new()
                    }
                    $parameters.Add($parameter)
                    $current = $parameter.Text
                }
                'EXAMPLE' {
                    $example = [ordered]@{
                        Code = [System.Collections.Generic.List[string]]::new()
                        Text = [System.Collections.Generic.List[string]]::new()
                    }
                    $examples.Add($example)
                    $current = $example.Code
                    $inExampleCode = $true
                    $exampleIndent = ([regex]::Match($line, '^\s*')).Value.Length
                }
                'LINK' {
                    if ($argument) {
                        $links.Add($argument.Trim())
                    }
                    $current = $ignored
                }
            }
            continue
        }

        # The first blank line inside an example ends the code and starts the text.
        if ($inExampleCode -and $line.Trim().Length -eq 0) {
            $current = $example.Text
            $inExampleCode = $false
            continue
        }

        if ($inExampleCode) {
            $strip = $exampleIndent + 4
            $codeLine = if ($line.Length -ge $strip) { $line.Substring($strip) } else { $line.TrimStart() }
            $current.Add($codeLine)
        }
        else {
            $current.Add($line.Trim())
        }
    }

    $parameterRows = @($parameters | ForEach-Object {
            [pscustomobject]@{
                Name = $_.Name
                Text = ConvertTo-CleanText -Text $_.Text
            }
        })

    $exampleRows = @($examples | ForEach-Object {
            [pscustomobject]@{
                Code = ConvertTo-CleanText -Text $_.Code
                Text = ConvertTo-CleanText -Text $_.Text
            }
        })

    [PSCustomObject]@{
        Found       = [bool]$block
        Synopsis    = ConvertTo-CleanText -Text $synopsis
        Description = ConvertTo-CleanText -Text $description
        Inputs      = ConvertTo-CleanText -Text $inputs
        Outputs     = ConvertTo-CleanText -Text $outputs
        Notes       = ConvertTo-CleanText -Text $notes
        Links       = $links.ToArray()
        Parameters  = $parameterRows
        Examples    = $exampleRows
    }
}
