Set-StrictMode -Version Latest

function Convert-CommentHelpToMarkdown {
    <#
    .SYNOPSIS
        Converts PowerShell comment-based help into Markdown documents.

    .DESCRIPTION
        Reads script files, extracts each comment-based help block, and writes one
        Markdown document per script. Sections are emitted in a stable order

        - FUNCTION
        - .SYNOPSIS
        - .DESCRIPTION,
        - .PARAMETERS,
        - .EXAMPLES,
        - .INPUTS,
        - .OUTPUTS,
        - .NOTES, and
        - .RELATED LINKS.

        Empty sections are omitted. Each example renders as a fenced powershell code block followed by
        its explanation, and the code is dedented by the keyword indent plus four
        spaces so the block reads as runnable PowerShell.

        Only `.ps1` files are processed. A directory under Path is searched recursively,
        so `-Path .\` collects every script in the tree. Wildcards are also supported,
        for example `.\Public\*.ps1`.

        The parser recognizes the common help keywords: SYNOPSIS, DESCRIPTION,
        PARAMETER, EXAMPLE, INPUTS, OUTPUTS, NOTES, and LINK. A script without a
        recognizable help block is reported in Errors instead of being skipped
        silently, so a documentation run over a whole tree shows exactly which files
        still need help written. Each generated document overwrites an existing .md
        file with the same name.

        Returns one summary object with counts, per-file Results, and Errors, matching
        the module's Compress-FileTree report shape. A request that matches no scripts
        terminates with an error.

    .PARAMETER Path
        Script files or directories to convert. Directories are searched recursively
        and wildcards are supported, for example .\Public\*.ps1. Only .ps1 files are
        processed.

    .PARAMETER OutPath
        Directory for the generated .md files, created when missing. When omitted,
        each file is written beside its source. Existing documents with the same name
        are overwritten.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject with TotalFiles, ConvertedFiles, FailedFiles, Results, and
        Errors. Results contains the individual records with Path and OutputPath for
        every document that was written. Errors contains Path and Message for files
        with no comment-based help and for conversion or write failures. ConvertedFiles
        plus FailedFiles equals TotalFiles.

    .EXAMPLE
        Convert-CommentHelpToMarkdown -Path .\Public\Get-AclItem.ps1

        Writes Get-AclItem.md next to the source file.

    .EXAMPLE
        $report = Convert-CommentHelpToMarkdown -Path .\Public\*.ps1 -OutPath .\Doc
        $report.Results | Format-Table Path, OutputPath

        Generates one Markdown file per public function under .\Doc and inspects the
        per-file records.

    .EXAMPLE
        $report = Convert-CommentHelpToMarkdown -Path .\
        $report.Errors | Format-Table Path, Message

        Recurses the current tree for .ps1 files and lists the scripts that still need
        help written.

    .NOTES
        Output names come from the function declaration inside the script when one is
        present, and from the file name otherwise, so a help block that documents a
        single function is headed under that function's name. Files are read with -Raw
        and written as UTF-8. Runs on Windows PowerShell 5.1 and PowerShell 7 on any
        platform.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # Script files or directories to convert. Directories are searched recursively.
        [Parameter(Mandatory = $true, HelpMessage = 'Enter the script files or directories to convert.')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # Directory for the generated .md files; created when missing.
        [Parameter(HelpMessage = 'Enter the output directory. Defaults to beside each source file.')]
        [string]$OutPath
    )

    $resolvedFiles = @()
    foreach ($entry in $Path) {
        $resolvedFiles += @(Get-ChildItem -Path $entry -Recurse -File -Filter '*.ps1' -ErrorAction SilentlyContinue)
    }

    if ($resolvedFiles.Count -eq 0) {
        throw "No files matched: $($Path -join ', ')"
    }

    if ($OutPath -and -not (Test-Path -LiteralPath $OutPath -PathType Container)) {
        [void](New-Item -Path $OutPath -ItemType Directory -Force)
    }

    $results = [System.Collections.Generic.List[object]]::new()
    $errors = [System.Collections.Generic.List[object]]::new()

    foreach ($file in $resolvedFiles) {
        try {
            $content = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
            $data = ConvertFrom-CommentHelp -Content $content

            if (-not $data.Found) {
                $missingHelp = [pscustomobject]@{
                    Path    = $file.FullName
                    Message = 'No comment-based help block was found in this file.'
                }

                $errors.Add($missingHelp)
                continue
            }

            # The function declaration wins over the file name so a help block that
            # documents one function is headed under that function's name.
            $name = $file.BaseName
            $functionMatch = [regex]::Match($content, '(?m)^\s*function\s+([\w-]+)')
            if ($functionMatch.Success) {
                $name = $functionMatch.Groups[1].Value
            }

            $markdown = Format-HelpMarkdown -Name $name -Data $data
            $outDirectory = if ($OutPath) { $OutPath } else { $file.DirectoryName }
            $outFile = Join-Path -Path $outDirectory -ChildPath "$($file.BaseName).md"

            Set-Content -LiteralPath $outFile -Value $markdown -Encoding utf8

            Write-Verbose -Message "Converted $($file.FullName) to $outFile"

            $result = [pscustomobject]@{
                Path       = $file.FullName
                OutputPath = $outFile
            }

            $results.Add($result)
        }
        catch {
            $failure = [pscustomobject]@{
                Path    = $file.FullName
                Message = $_.Exception.Message
            }

            $errors.Add($failure)
        }
    }

    [pscustomobject]@{
        TotalFiles     = $resolvedFiles.Count
        ConvertedFiles = $results.Count
        FailedFiles    = $errors.Count
        Results        = $results.ToArray()
        Errors         = $errors.ToArray()
    }
}
