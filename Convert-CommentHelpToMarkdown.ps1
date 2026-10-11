<#
.SYNOPSIS
    Converts PowerShell comment-based help into Markdown.

.DESCRIPTION
    Reads one or more script files, extracts the comment-based help block, and
    renders it as a Markdown document.

    The parser understands the common help keywords .SYNOPSIS, .DESCRIPTION,
    .PARAMETER, .EXAMPLE, .INPUTS, .OUTPUTS, .NOTES, and .LINK. Sections are
    emitted in a stable order and examples are split into a fenced code block
    followed by their explanation.

.PARAMETER Path
    One or more script files. Wildcards are supported.

.PARAMETER OutputDirectory
    Directory for the generated .md files. When omitted, each file is written
    beside its source.

.EXAMPLE
    .\Convert-CommentHelpToMarkdown.ps1 -Path .\Public\Get-AclItem.ps1

    Writes Get-AclItem.md next to the source file.

.EXAMPLE
    .\Convert-CommentHelpToMarkdown.ps1 -Path .\Public\*.ps1 -OutputDirectory .\Doc

    Generates one Markdown file per public function under .\Doc.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Path,

    [string]$OutputDirectory
)

Set-StrictMode -Version Latest

function Convert-CommentHelpToMarkdown {
    <#
    .SYNOPSIS
        Converts the comment-based help of a single script into Markdown.

    .PARAMETER Path
        Script file to convert.

    .OUTPUTS
        System.String. The rendered Markdown document.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $content = Get-Content -LiteralPath $Path -Raw

    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $functionMatch = [regex]::Match($content, '(?m)^\s*function\s+([\w-]+)')
    if ($functionMatch.Success) {
        $name = $functionMatch.Groups[1].Value
    }

    $lines = Get-HelpBlockLines -Content $content
    if ($null -eq $lines) {
        Write-Warning "No comment-based help found in '$Path'. Skipping."
        return
    }

    $data = ConvertFrom-HelpBlock -Lines $lines
    return Format-HelpMarkdown -Name $name -Data $data
}

function Get-HelpBlockLines {
    <#
    .SYNOPSIS
        Returns the lines of the first comment block that looks like help.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $keywords = 'SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE|INPUTS|OUTPUTS|NOTES|LINK'
    $block = [regex]::Matches($Content, '(?s)<#(?<body>.*?)#>') |
        Where-Object { $_.Groups['body'].Value -match "(?m)^\s*\.($keywords)\b" } |
        Select-Object -First 1

    if ($null -eq $block) {
        return $null
    }

    return @($block.Groups['body'].Value -split "`r?`n")
}

function ConvertFrom-HelpBlock {
    <#
    .SYNOPSIS
        Parses raw help lines into an ordered data structure.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$Lines
    )

    $keywords = 'SYNOPSIS|DESCRIPTION|PARAMETER|EXAMPLE|INPUTS|OUTPUTS|NOTES|LINK'
    $keywordPattern = [regex]"^\s*\.(?<keyword>$keywords)(?:\s+(?<arg>.*))?$"

    $synopsis    = [System.Collections.Generic.List[string]]::new()
    $description = [System.Collections.Generic.List[string]]::new()
    $inputs      = [System.Collections.Generic.List[string]]::new()
    $outputs     = [System.Collections.Generic.List[string]]::new()
    $notes       = [System.Collections.Generic.List[string]]::new()
    $links       = [System.Collections.Generic.List[string]]::new()
    $parameters  = [System.Collections.Generic.List[object]]::new()
    $examples    = [System.Collections.Generic.List[object]]::new()

    $current = $null
    $currentExampleText = $null
    $inExampleCode = $false
    $exampleIndent = 0

    foreach ($line in $Lines) {
        $match = $keywordPattern.Match($line)
        if ($match.Success) {
            $keyword = $match.Groups['keyword'].Value.ToUpperInvariant()
            $arg = $match.Groups['arg'].Value
            switch ($keyword) {
                'SYNOPSIS'    { $current = $synopsis; $inExampleCode = $false; break }
                'DESCRIPTION' { $current = $description; $inExampleCode = $false; break }
                'INPUTS'      { $current = $inputs; $inExampleCode = $false; break }
                'OUTPUTS'     { $current = $outputs; $inExampleCode = $false; break }
                'NOTES'       { $current = $notes; $inExampleCode = $false; break }
                'PARAMETER' {
                    $param = [ordered]@{
                        Name = $arg.Trim()
                        Text = [System.Collections.Generic.List[string]]::new()
                    }
                    $parameters.Add($param)
                    $current = $param.Text
                    $inExampleCode = $false
                    break
                }
                'EXAMPLE' {
                    $exampleCode = [System.Collections.Generic.List[string]]::new()
                    $exampleText = [System.Collections.Generic.List[string]]::new()
                    $examples.Add([ordered]@{ Code = $exampleCode; Text = $exampleText })
                    $current = $exampleCode
                    $currentExampleText = $exampleText
                    $inExampleCode = $true
                    $exampleIndent = ([regex]::Match($line, '^\s*')).Value.Length
                    break
                }
                'LINK' {
                    if ($arg) { $links.Add($arg.Trim()) }
                    $current = $null
                    $inExampleCode = $false
                    break
                }
                default {
                    $current = $null
                    $inExampleCode = $false
                    break
                }
            }
            continue
        }

        if ($null -eq $current) {
            continue
        }

        # The first blank line inside an example ends the code and starts the text.
        if ($inExampleCode -and $line.Trim().Length -eq 0) {
            $current = $currentExampleText
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

    return [pscustomobject]@{
        Synopsis    = ConvertTo-CleanText -Text $synopsis
        Description = ConvertTo-CleanText -Text $description
        Inputs      = ConvertTo-CleanText -Text $inputs
        Outputs     = ConvertTo-CleanText -Text $outputs
        Notes       = ConvertTo-CleanText -Text $notes
        Links       = $links.ToArray()
        Parameters  = @($parameters | ForEach-Object {
                [pscustomobject]@{
                    Name = $_.Name
                    Text = ConvertTo-CleanText -Text $_.Text
                }
            })
        Examples    = @($examples | ForEach-Object {
                [pscustomobject]@{
                    Code = ConvertTo-CleanText -Text $_.Code
                    Text = ConvertTo-CleanText -Text $_.Text
                }
            })
    }
}

function ConvertTo-CleanText {
    <#
    .SYNOPSIS
        Joins text lines and strips leading and trailing blank lines.
    #>
    [CmdletBinding()]
    param(
        [AllowNull()]
        [System.Collections.Generic.List[string]]$Text
    )

    if ($null -eq $Text -or $Text.Count -eq 0) {
        return ''
    }

    $items = $Text.ToArray()
    $first = 0
    $last = $items.Length - 1
    while ($first -le $last -and $items[$first].Trim().Length -eq 0) { $first++ }
    while ($last -ge $first -and $items[$last].Trim().Length -eq 0) { $last-- }
    if ($first -gt $last) {
        return ''
    }

    return ($items[$first..$last] -join "`n")
}

function Format-HelpMarkdown {
    <#
    .SYNOPSIS
        Renders parsed help data as a Markdown document.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
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
        foreach ($param in $Data.Parameters) {
            $out.Add("### -$($param.Name)")
            $out.Add('')
            $out.Add($param.Text)
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

$resolvedFiles = foreach ($entry in $Path) {
    Get-ChildItem -Path $entry -File -ErrorAction SilentlyContinue
}

if ($null -eq $resolvedFiles -or @($resolvedFiles).Count -eq 0) {
    throw "No files matched: $($Path -join ', ')"
}

if ($OutputDirectory -and -not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    $null = New-Item -Path $OutputDirectory -ItemType Directory -Force
}

foreach ($file in $resolvedFiles) {
    $markdown = Convert-CommentHelpToMarkdown -Path $file.FullName
    if ($null -eq $markdown) { continue }
    $outDirectory = if ($OutputDirectory) { $OutputDirectory } else { $file.DirectoryName }
    $outFile = Join-Path -Path $outDirectory -ChildPath "$($file.BaseName).md"
    Set-Content -LiteralPath $outFile -Value $markdown -Encoding utf8
    Write-Host "Wrote $outFile"
}
