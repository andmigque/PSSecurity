if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Split-SudoersList {
        <#
    .SYNOPSIS
        Splits a sudoers element list on commas outside parentheses and quotes.

    .DESCRIPTION
        Sudoers separates the elements of a command list or an alias value with commas, but a
        comma inside a runas parenthesis or inside a quoted command argument belongs to that
        element. The split therefore tracks parenthesis depth, double-quoted strings, and
        backslash escapes, and returns the trimmed non-empty elements in their original order.

    .PARAMETER Value
        The sudoers element list to split, for example (root) /bin/kill, /usr/bin/lprm.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.String[]. The trimmed, non-empty elements in their original order.

    .EXAMPLE
        Split-SudoersList -Value '(root) NOPASSWD: /bin/kill, /usr/bin/lprm'

        Returns the two elements with the runas parenthesis and tag left intact for the caller.
    #>
        [CmdletBinding()]
        [OutputType([string[]])]
        param(
            # The sudoers element list to split.
            [Parameter(Mandatory = $true, HelpMessage = 'Enter the sudoers element list to split.')]
            [string]$Value
        )

        $elements = [System.Collections.Generic.List[string]]::new()
        $current = [System.Text.StringBuilder]::new()
        $parenDepth = 0
        $inQuote = $false
        $escaped = $false

        foreach ($character in $Value.ToCharArray()) {
            if ($escaped) {
                [void]$current.Append($character)
                $escaped = $false
                continue
            }

            if ($character -eq '\') {
                [void]$current.Append($character)
                $escaped = $true
                continue
            }

            if ($inQuote) {
                if ($character -eq '"') {
                    $inQuote = $false
                }
                [void]$current.Append($character)
                continue
            }

            if ($character -eq '"') {
                $inQuote = $true
                [void]$current.Append($character)
                continue
            }

            if ($character -eq '(') {
                $parenDepth++
                [void]$current.Append($character)
                continue
            }

            if ($character -eq ')') {
                if ($parenDepth -gt 0) {
                    $parenDepth--
                }
                [void]$current.Append($character)
                continue
            }

            if ($character -eq ',' -and $parenDepth -eq 0) {
                $element = $current.ToString().Trim()
                if ($element) {
                    $elements.Add($element)
                }
                [void]$current.Clear()
                continue
            }

            [void]$current.Append($character)
        }

        $element = $current.ToString().Trim()
        if ($element) {
            $elements.Add($element)
        }

        return $elements.ToArray()
    }
}
