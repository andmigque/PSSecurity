if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Set-LoginDefPolicy {
        <#
    .SYNOPSIS
        Applies the module's CIS login.defs table on Linux.

    .DESCRIPTION
        Rewrites the shadow login defaults in /etc/login.defs so password aging follows
        the CIS Distribution Independent Linux benchmark: every active parameter in the
        table gets the configured value, duplicate active definitions are removed so one
        value cannot shadow another, and parameters missing from the file are appended.
        Commented lines and everything else in the file are preserved.

        The change affects accounts created or updated afterwards. Existing users keep
        their current aging until an administrator updates them with chage, which this
        function deliberately does not do.

        A non-root session writes the file through sudo, which may prompt for a password.

    .PARAMETER Table
        The login.defs parameters to apply, each entry a hashtable with Key and Value.
        Defaults to the module's LoginDefPolicy setting from Config/Setting.psd1.

    .PARAMETER Path
        The login.defs file to edit. Defaults to the module's LoginDefsPath setting.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject per parameter with Key, Before, After, and Status. Before is
        the first active value in the file or Absent when the parameter is not set.
        Status is Compliant when the file already carries exactly the configured value,
        Preview under -WhatIf, Hardened when the edit was applied and verified, and
        Failed when the write or the verification failed. When the file is written, one
        string summarizes the run with the file it edited and how many parameters changed.

    .EXAMPLE
        Set-LoginDefPolicy -WhatIf

        Previews the password aging edits the table would make to /etc/login.defs.

    .EXAMPLE
        Set-LoginDefPolicy

        Applies the configured password aging defaults to /etc/login.defs.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. The default
        table comes from the LoginDefPolicy key in Config/Setting.psd1. Per-user limits
        set with chage are a separate benchmark control and stay untouched.
    #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([pscustomobject], [string])]
        param (
            # Parameters to apply. Defaults to the module's LoginDefPolicy setting.
            [Parameter(HelpMessage = 'Enter a table of Key and Value entries. Defaults to the LoginDefPolicy setting.')]
            [ValidateNotNullOrEmpty()]
            [hashtable[]]$Table = $script:LoginDefPolicy,

            # The login.defs file to edit.
            [Parameter(HelpMessage = 'Enter the login.defs file to edit.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path = $script:LoginDefsPath
        )

        $sessionIsRoot = (& id -u) -eq 0

        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            throw "login.defs was not found at $Path."
        }

        if (-not $sessionIsRoot -and -not $WhatIfPreference -and -not (Get-Command -Name sudo -ErrorAction SilentlyContinue)) {
            throw 'sudo was not found on this system. Run as root instead.'
        }

        $lines = [System.Collections.Generic.List[string]]::new()
        foreach ($line in @(Get-Content -LiteralPath $Path)) {
            [void]$lines.Add($line)
        }

        $plans = [System.Collections.Generic.List[pscustomobject]]::new()

        foreach ($entry in $Table) {
            $key = [string]$entry['Key']
            $value = [string]$entry['Value']

            if (-not $key -or -not $value -or
                $key -notmatch '^[A-Z][A-Z0-9_]*$' -or $value -notmatch '^[A-Za-z0-9._-]+$') {
                Write-Error -Message "Invalid table entry: '$key' = '$value'."
                continue
            }

            $pattern = '^\s*{0}\s+(\S+)\s*$' -f [regex]::Escape($key)
            $activeIndexes = @()
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match $pattern) {
                    $activeIndexes += $i
                }
            }

            $before = 'Absent'
            if ($activeIndexes.Count -gt 0) {
                $before = $lines[$activeIndexes[0]] -replace $pattern, '$1'
            }

            $plan = [PSCustomObject]@{
                Key        = $key
                Value      = $value
                Before     = $before
                Indexes    = $activeIndexes
                AlreadySet = ($before -eq $value -and $activeIndexes.Count -eq 1)
            }

            [void]$plans.Add($plan)
        }

        foreach ($plan in $plans) {
            if ($plan.AlreadySet) {
                continue
            }

            if ($plan.Indexes.Count -gt 0) {
                $lines[$plan.Indexes[0]] = "$($plan.Key) $($plan.Value)"

                for ($i = $plan.Indexes.Count - 1; $i -ge 1; $i--) {
                    [void]$lines.RemoveAt($plan.Indexes[$i])
                }
            }
            else {
                [void]$lines.Add("$($plan.Key) $($plan.Value)")
            }
        }

        $applied = $false
        $declined = $false

        if ($PSCmdlet.ShouldProcess($Path, 'Set login.defs parameters')) {
            try {
                if ($sessionIsRoot) {
                    $lines | Set-Content -LiteralPath $Path -ErrorAction Stop
                    $applied = $true
                }
                else {
                    $lines | sudo tee -- $Path | Out-Null
                    $applied = ($LASTEXITCODE -eq 0)
                }
            }
            catch {
                $applied = $false
            }

            if (-not $applied) {
                Write-Error -Message "Could not write $Path."
            }
        }
        else {
            $declined = $true
        }

        $verifiedLines = @()
        if ($applied) {
            $verifiedLines = @(Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue)
        }

        $hardenedCount = 0

        foreach ($plan in $plans) {
            $verifyPattern = '^\s*{0}\s+{1}\s*$' -f [regex]::Escape($plan.Key), [regex]::Escape($plan.Value)
            $activeAfter = @($verifiedLines | Where-Object { $_ -match $verifyPattern })
            $isConfigured = ($activeAfter.Count -eq 1)

            if ($plan.AlreadySet) {
                $status = 'Compliant'
            }
            elseif ($declined) {
                $status = 'Preview'
            }
            elseif ($applied -and $isConfigured) {
                $status = 'Hardened'
            }
            else {
                $status = 'Failed'
            }

            if ($status -eq 'Hardened') {
                $hardenedCount++
            }

            $after = if ($applied -or $declined) { $plan.Value } else { $plan.Before }

            [PSCustomObject]@{ Key = $plan.Key; Before = $plan.Before; After = $after; Status = $status }
        }

        if ($applied) {
            $summary = if ($hardenedCount -gt 0) {
                "Set $hardenedCount of $($plans.Count) parameters in $Path."
            }
            else {
                "All $($plans.Count) parameters were already set in $Path."
            }

            Write-Output $summary
        }
    }
}
