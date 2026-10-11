if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Set-SysctlHardening {
        <#
    .SYNOPSIS
        Applies the module's CIS-style kernel parameter table on Linux.

    .DESCRIPTION
        Reads the live value of every kernel parameter in the table and applies the target
        value with sysctl -w where the running kernel disagrees, then verifies each change
        took effect. Parameters already at their target are reported as Compliant and never
        touch sudo. A key the running kernel does not know is reported as Missing and
        skipped, so one table can be tuned per distribution without failing the whole run.

        Runtime changes do not survive a reboot. -Persist also writes the full table to
        /etc/sysctl.d/99-pssecurity-hardening.conf, which the kernel applies at boot. The
        file is rewritten on every run so it always mirrors the table, and the 99- prefix
        keeps it ahead of distribution defaults in the sysctl.d load order.

        A non-root session applies changes and writes the persisted file through sudo, which
        may prompt for a password.

    .PARAMETER Table
        The kernel parameters to apply, each entry a hashtable with Key and Value. Defaults
        to the module's SysctlHardening setting from Config/Setting.psd1.

    .PARAMETER Persist
        Also writes the table to /etc/sysctl.d/99-pssecurity-hardening.conf so the values
        survive reboot.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject per parameter with Key, Before, After, and Status. Status is
        Compliant when the live value already matches, Preview under -WhatIf, Hardened when
        the verified value now matches the target, Failed when sysctl or the verification
        failed, and Missing when the kernel does not know the key. When -Persist succeeds,
        one string confirms the file it wrote.

    .EXAMPLE
        Set-SysctlHardening -WhatIf

        Previews every kernel parameter change the table would make without applying it.

    .EXAMPLE
        Set-SysctlHardening -Persist

        Applies the configured table at runtime and writes it to /etc/sysctl.d so it
        survives reboot.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. The default table
        comes from the SysctlHardening key in Config/Setting.psd1. net.ipv4.ip_forward=0
        stops packet forwarding, so pass a custom -Table on router or container hosts that
        need forwarding.
    #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([pscustomobject], [string])]
        param (
            # Kernel parameters to apply. Defaults to the module's SysctlHardening setting.
            [Parameter(HelpMessage = 'Enter a table of Key and Value entries. Defaults to the SysctlHardening setting.')]
            [ValidateNotNullOrEmpty()]
            [hashtable[]]$Table = $script:SysctlHardening,

            # Write the table to /etc/sysctl.d so it survives reboot.
            [Parameter(HelpMessage = 'Persist the table to /etc/sysctl.d/99-pssecurity-hardening.conf.')]
            [switch]$Persist
        )

        $sessionIsRoot = (& id -u) -eq 0
        $persistPath = '/etc/sysctl.d/99-pssecurity-hardening.conf'

        if (-not $sessionIsRoot -and -not $WhatIfPreference -and -not (Get-Command -Name sudo -ErrorAction SilentlyContinue)) {
            throw 'sudo was not found on this system. Run as root instead.'
        }

        $persistLines = [System.Collections.Generic.List[string]]::new()
        [void]$persistLines.Add('# Managed by PSSecurity Set-SysctlHardening. Rewritten on every run.')

        foreach ($entry in $Table) {
            $key = [string]$entry['Key']
            $value = [string]$entry['Value']

            if (-not $key -or -not $value -or
                $key -notmatch '^[A-Za-z0-9._-]+$' -or $value -notmatch '^[A-Za-z0-9 ,._-]+$') {
                Write-Error -Message "Invalid table entry: '$key' = '$value'."
                continue
            }

            $before = (& sysctl -n -- $key 2>$null)

            if ($LASTEXITCODE -ne 0) {
                Write-Verbose -Message "The running kernel does not know $key."
                [PSCustomObject]@{ Key = $key; Before = $null; After = $null; Status = 'Missing' }
                continue
            }

            [void]$persistLines.Add("$key = $value")
            $before = "$before".Trim()

            if ($before -eq $value) {
                [PSCustomObject]@{ Key = $key; Before = $before; After = $before; Status = 'Compliant' }
                continue
            }

            if (-not $PSCmdlet.ShouldProcess($key, "Set kernel parameter to $value")) {
                [PSCustomObject]@{ Key = $key; Before = $before; After = $value; Status = 'Preview' }
                continue
            }

            if ($sessionIsRoot) {
                & sysctl -w -- "$key=$value" | Out-Null
            }
            else {
                & sudo sysctl -w -- "$key=$value" | Out-Null
            }

            if ($LASTEXITCODE -ne 0) {
                Write-Error -Message "sysctl -w failed for $key."
                [PSCustomObject]@{ Key = $key; Before = $before; After = $before; Status = 'Failed' }
                continue
            }

            $after = (& sysctl -n -- $key 2>$null)
            $after = "$after".Trim()
            $status = if ($after -eq $value) { 'Hardened' } else { 'Failed' }

            [PSCustomObject]@{ Key = $key; Before = $before; After = $after; Status = $status }
        }

        if ($Persist -and $PSCmdlet.ShouldProcess($persistPath, 'Write persistent sysctl table')) {
            try {
                if ($sessionIsRoot) {
                    $persistLines | Set-Content -LiteralPath $persistPath -ErrorAction Stop
                    Write-Output "Persisted the table to $persistPath."
                }
                else {
                    $persistLines | sudo tee -- $persistPath | Out-Null

                    if ($LASTEXITCODE -eq 0) {
                        Write-Output "Persisted the table to $persistPath."
                    }
                    else {
                        Write-Warning -Message "Could not persist the table to $persistPath."
                    }
                }
            }
            catch {
                Write-Error -Message "Could not persist the table to $persistPath."
            }
        }
    }
}
