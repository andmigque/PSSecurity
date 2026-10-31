#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function ConvertTo-CleanText {
    <#
    .SYNOPSIS
        Joins text lines and strips leading and trailing blank lines.

    .DESCRIPTION
        Joins the lines with newlines after removing blank or whitespace-only lines from
        the start and end. Blank lines in the middle are kept. Used by
        ConvertFrom-CommentHelp to tidy each help section.

    .PARAMETER Text
        The lines to join. May be null or empty, because help sections are often empty.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.String. The joined text, or an empty string when there is no content.

    .EXAMPLE
        $lines = [System.Collections.Generic.List[string]]@('', 'First line', '', 'Last line', '  ')
        ConvertTo-CleanText -Text $lines

        Returns "First line`n`nLast line".
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Not mandatory: a mandatory collection rejects a list containing an empty string.
        [Parameter(HelpMessage = 'Enter the lines to join.')]
        [AllowNull()]
        [System.Collections.Generic.List[string]]$Text
    )

    if ($null -eq $Text -or $Text.Count -eq 0) {
        return ''
    }

    $items = $Text.ToArray()
    $first = 0
    $last = $items.Length - 1

    while ($first -le $last -and $items[$first].Trim().Length -eq 0) {
        $first++
    }

    while ($last -ge $first -and $items[$last].Trim().Length -eq 0) {
        $last--
    }

    if ($first -gt $last) {
        return ''
    }

    $items[$first..$last] -join "`n"
}
