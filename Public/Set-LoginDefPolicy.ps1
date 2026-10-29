#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Set-LoginDefPolicy {
        <#
        .SYNOPSIS
            Applies the CIS login.defs table on Linux.

        .DESCRIPTION
            Sets every key in the table to its configured value in /etc/login.defs. The
            first active definition of each key takes the configured value, later duplicates
            are removed so no second definition can override it, and keys the file never
            defined are appended. Comments and every other line are kept. The file is
            written only when at least one key changes, then read back to verify each key.

            The change applies to accounts created or updated afterwards. Existing accounts
            keep their password aging until an administrator updates them with chage.

        .PARAMETER Table
            The login.defs keys to apply, each a hashtable with Key and Value. Defaults to
            the module's LoginDefPolicy setting.

        .PARAMETER Path
            The login.defs file to edit. Defaults to the module's LoginDefsPath setting.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. Key, Before, After, and Status for
            each key. Before is the value in effect, or Absent. Status is Compliant, Preview,
            Hardened, or Failed.

        .EXAMPLE
            Set-LoginDefPolicy -WhatIf

            Previews the password aging changes to /etc/login.defs.

        .EXAMPLE
            Invoke-Sudo { Import-Module PSSecurity; Set-LoginDefPolicy }

            Applies the password aging table as root.

        .NOTES
            Run as root. Per-account aging set with chage is a separate benchmark control.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([pscustomobject])]
        param(
            [Parameter(HelpMessage = 'Enter a table of Key and Value entries.')]
            [ValidateNotNullOrEmpty()]
            [hashtable[]]$Table = $script:LoginDefPolicy,

            [Parameter(HelpMessage = 'Enter the login.defs file to edit.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path = $script:LoginDefsPath
        )

        $lines = @(Get-Content -LiteralPath $Path -ErrorAction Stop)

        $entries = @(foreach ($entry in $Table) {
                $key = [string]$entry['Key']
                $value = [string]$entry['Value']

                # Keys and values land in a root-owned file read by login, useradd, and
                # passwd, so both are limited to the characters login.defs uses. This also
                # blocks a newline that would smuggle in a second setting.
                if ($key -cnotmatch '^[A-Z][A-Z0-9_]*$' -or $value -notmatch '^[A-Za-z0-9._-]+$') {
                    Write-Error -Message "Invalid table entry: '$key' = '$value'."
                    continue
                }

                # An active definition is the key and one value on an uncommented line.
                # Keys are case-sensitive in login.defs.
                $pattern = '^\s*{0}\s+(\S+)\s*$' -f [regex]::Escape($key)
                $active = @($lines -cmatch $pattern)

                # When a key is defined more than once, the shadow tools keep the last
                # definition, so the last match is the value currently in effect.
                $before = if ($active) { $active[-1] -creplace $pattern, '$1' } else { 'Absent' }

                [pscustomobject]@{
                    Key       = $key
                    Value     = $value
                    Pattern   = $pattern
                    Before    = $before
                    Compliant = $active.Count -eq 1 -and $before -ceq $value
                }
            })

        # Rebuild the file in one pass: the first active definition of each key becomes the
        # configured value, later duplicates are dropped, and every other line is kept.
        # Editing a line list in place by saved index shifts the remaining indexes after the
        # first removal and overwrites the wrong lines.
        $placed = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        $newLines = [System.Collections.Generic.List[string]]::new()

        foreach ($line in $lines) {
            $definition = $entries.Where({ $line -cmatch $_.Pattern }, 'First')
            if ($definition.Count -eq 0) {
                $newLines.Add($line)
                continue
            }

            if ($placed.Add($definition[0].Key)) {
                $newLines.Add(('{0} {1}' -f $definition[0].Key, $definition[0].Value))
            }
        }

        # Keys the file never defined go at the end.
        foreach ($entry in $entries) {
            if ($placed.Add($entry.Key)) {
                $newLines.Add(('{0} {1}' -f $entry.Key, $entry.Value))
            }
        }

        $state = 'Unchanged'
        $writeError = $null
        $verifiedLines = @()

        if ($entries.Where({ -not $_.Compliant }).Count -gt 0) {
            if ($PSCmdlet.ShouldProcess($Path, 'Set login.defs keys')) {
                try {
                    # Set-Content truncates and rewrites the existing file, so its owner,
                    # mode, and SELinux label stay as they were.
                    Set-Content -LiteralPath $Path -Value $newLines -ErrorAction Stop
                    $verifiedLines = @(Get-Content -LiteralPath $Path -ErrorAction Stop)
                    $state = 'Written'
                }
                catch {
                    $writeError = $_
                    $state = 'Failed'
                }
            }
            else {
                $state = 'Preview'
            }
        }

        foreach ($entry in $entries) {
            $after = $entry.Before
            $status = 'Failed'

            if ($entry.Compliant) {
                $status = 'Compliant'
            }
            elseif ($state -eq 'Preview') {
                $after = $entry.Value
                $status = 'Preview'
            }
            elseif ($state -eq 'Written') {
                # Verify against the file on disk: exactly one active definition, holding
                # the configured value.
                $activeAfter = @($verifiedLines -cmatch $entry.Pattern)
                $after = if ($activeAfter) { $activeAfter[-1] -creplace $entry.Pattern, '$1' } else { 'Absent' }
                if ($activeAfter.Count -eq 1 -and $after -ceq $entry.Value) {
                    $status = 'Hardened'
                }
            }

            [pscustomobject]@{ Key = $entry.Key; Before = $entry.Before; After = $after; Status = $status }

            if ($status -eq 'Failed' -and $state -eq 'Written') {
                Write-Error -Message "$($entry.Key) reads '$after' in $Path after writing."
            }
        }

        if ($writeError) {
            Write-Error -ErrorRecord $writeError
        }
    }
}
