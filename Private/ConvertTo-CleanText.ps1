Set-StrictMode -Version Latest

function ConvertTo-CleanText {
    <#
    .SYNOPSIS
        Joins text lines and strips leading and trailing blank lines.

    .PARAMETER Text
        Lines to join into one block of text.

    .OUTPUTS
        System.String. The joined text without leading or trailing blank lines, or an
        empty string when there is no content.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Lines to join into one block of text. Not mandatory: sections are often empty,
        # and a mandatory collection rejects a list containing an empty string.
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

    return ($items[$first..$last] -join "`n")
}
