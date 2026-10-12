if ($IsLinux) {
    Set-StrictMode -Version Latest

    function Set-LinuxFilePermission {
        <#
    .SYNOPSIS
        Applies the module's CIS ownership and mode table to Linux system files.

    .DESCRIPTION
        Reads the current owner, group, and mode of every file in the table and repairs it
        toward the CIS Distribution Independent Linux floor. The floor is intentionally
        permissive where the benchmark allows it: a file whose mode is already more
        restrictive than the floor is reported as Compliant and left alone, and a group
        the benchmark accepts as an alternative, such as root or shadow on the shadow
        files, is kept instead of being rewritten. Only files granting more access than
        the floor are changed with chown and chmod, and the result is verified with stat.

        Files listed in the table but absent from the system, such as the account database
        backups, are reported as Missing and skipped so one table survives across
        distributions.

        A non-root session applies changes through sudo, which may prompt for a password.

    .PARAMETER Table
        The files to repair, each entry a hashtable with Path, Owner, Group, and Mode.
        Defaults to the module's LinuxFilePermissions setting from Config/Setting.psd1.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        One PSCustomObject per file with Path, Before, After, and Status. Before and After
        carry the owner, group, and four digit mode, for example root:shadow 0640. Status
        is Compliant when the file already meets the floor, Preview under -WhatIf,
        Hardened when the change was applied and verified, Failed when chown, chmod, or
        the verification failed, and Missing when the file does not exist.

    .EXAMPLE
        Set-LinuxFilePermission -WhatIf

        Previews the ownership and mode repairs for every file in the table.

    .EXAMPLE
        Set-LinuxFilePermission

        Repairs the account databases, wrapper lists, and login banners to the CIS floor.

    .NOTES
        Runs on Linux only; in WSL, run it inside the target distribution. The default
        table comes from the LinuxFilePermissions key in Config/Setting.psd1. Pass a
        custom -Table to add distribution-specific targets such as the bootloader
        configuration.
    #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([pscustomobject])]
        param (
            # Files to repair. Defaults to the module's LinuxFilePermissions setting.
            [Parameter(HelpMessage = 'Enter Path, Owner, Group, and Mode entries. Defaults to the LinuxFilePermissions setting.')]
            [ValidateNotNullOrEmpty()]
            [hashtable[]]$Table = $script:LinuxFilePermissions
        )

        $sessionIsRoot = (& id -u) -eq 0

        if (-not $sessionIsRoot -and -not $WhatIfPreference -and -not (Get-Command -Name sudo -ErrorAction SilentlyContinue)) {
            throw 'sudo was not found on this system. Run as root instead.'
        }

        # 07777 covers the permission bits plus setuid, setgid, and sticky.
        $modeMask = [Convert]::ToInt32('7777', 8)

        foreach ($entry in $Table) {
            $targetPath = [string]$entry['Path']
            $owner = [string]$entry['Owner']
            $group = [string]$entry['Group']
            $mode = [string]$entry['Mode']

            if (-not $targetPath -or -not $owner -or -not $group -or $mode -notmatch '^[0-7]{3,4}$') {
                Write-Error -Message "Invalid table entry for '$targetPath'."
                continue
            }

            if (-not (Test-Path -LiteralPath $targetPath)) {
                Write-Verbose -Message "$targetPath does not exist on this system."
                [PSCustomObject]@{ Path = $targetPath; Before = $null; After = $null; Status = 'Missing' }
                continue
            }

            $statOutput = (& stat -c '%a %U %G' -- $targetPath 2>$null)

            if ($LASTEXITCODE -ne 0 -or -not $statOutput) {
                Write-Error -Message "stat failed for $targetPath."
                [PSCustomObject]@{ Path = $targetPath; Before = $null; After = $null; Status = 'Failed' }
                continue
            }

            $statParts = "$statOutput" -split '\s+'
            $currentMode = [Convert]::ToInt32($statParts[0], 8)
            $beforeOwner = $statParts[1]
            $beforeGroup = $statParts[2]
            $beforeMode = [Convert]::ToString($currentMode, 8).PadLeft(4, '0')
            $before = "$beforeOwner`:$beforeGroup $beforeMode"

            $floor = [Convert]::ToInt32($mode, 8)
            $modeCompliant = ((($currentMode -band (-bnot $floor)) -band $modeMask) -eq 0)

            # The benchmark accepts the configured group and, on the shadow files, root.
            $acceptableGroups = @($owner, $group) | Select-Object -Unique
            $needsOwner = $beforeOwner -ne $owner
            $needsGroup = -not ($acceptableGroups -contains $beforeGroup)
            $needsMode = -not $modeCompliant

            $afterOwner = if ($needsOwner) { $owner } else { $beforeOwner }
            $afterGroup = if ($needsGroup) { $group } else { $beforeGroup }
            $afterMode = if ($needsMode) { $floor } else { $currentMode }
            $afterModeText = [Convert]::ToString($afterMode, 8).PadLeft(4, '0')
            $after = "$afterOwner`:$afterGroup $afterModeText"

            if (-not ($needsOwner -or $needsGroup -or $needsMode)) {
                [PSCustomObject]@{ Path = $targetPath; Before = $before; After = $before; Status = 'Compliant' }
                continue
            }

            if (-not $PSCmdlet.ShouldProcess($targetPath, "Set owner, group, and mode to $after")) {
                [PSCustomObject]@{ Path = $targetPath; Before = $before; After = $after; Status = 'Preview' }
                continue
            }

            if ($needsOwner -or $needsGroup) {
                $chownSpec = if ($needsGroup) { "${owner}:$group" } else { $owner }

                if ($sessionIsRoot) {
                    & chown -- $chownSpec $targetPath
                }
                else {
                    & sudo chown -- $chownSpec $targetPath
                }

                if ($LASTEXITCODE -ne 0) {
                    Write-Error -Message "chown failed for $targetPath."
                    [PSCustomObject]@{ Path = $targetPath; Before = $before; After = $before; Status = 'Failed' }
                    continue
                }
            }

            if ($needsMode) {
                if ($sessionIsRoot) {
                    & chmod -- $mode $targetPath
                }
                else {
                    & sudo chmod -- $mode $targetPath
                }

                if ($LASTEXITCODE -ne 0) {
                    Write-Error -Message "chmod failed for $targetPath."
                    [PSCustomObject]@{ Path = $targetPath; Before = $before; After = $before; Status = 'Failed' }
                    continue
                }
            }

            $verifyOutput = (& stat -c '%a %U %G' -- $targetPath 2>$null)

            if ($LASTEXITCODE -ne 0 -or -not $verifyOutput) {
                Write-Error -Message "stat failed for $targetPath after the change."
                [PSCustomObject]@{ Path = $targetPath; Before = $before; After = $before; Status = 'Failed' }
                continue
            }

            $verifyParts = "$verifyOutput" -split '\s+'
            $verifiedMode = [Convert]::ToInt32($verifyParts[0], 8)
            $verifiedModeText = [Convert]::ToString($verifiedMode, 8).PadLeft(4, '0')
            $verified = "$($verifyParts[1]):$($verifyParts[2]) $verifiedModeText"
            $verifiedCompliant = (
                $verifyParts[1] -eq $owner -and
                $acceptableGroups -contains $verifyParts[2] -and
                ((($verifiedMode -band (-bnot $floor)) -band $modeMask) -eq 0)
            )
            $status = if ($verifiedCompliant) { 'Hardened' } else { 'Failed' }

            [PSCustomObject]@{ Path = $targetPath; Before = $before; After = $verified; Status = $status }
        }
    }
}
