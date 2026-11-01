#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Set-LinuxFilePermission {
        <#
        .SYNOPSIS
            Tightens the owner and mode of system files, cron directories, and home
            directories to a rule table.

        .DESCRIPTION
            Reads the rules in Config/LinuxFilePermission.psd1, or the file given with
            -LiteralPath, and applies each one to every path it matches. The rules cover the
            account databases, login banners, cron directories, and home directories, using
            only values that hold on every distribution.

            Mode is a floor: bits the rule does not allow are removed, and none are added,
            so a repair never grants access a path did not already have. Owner and Group,
            when a rule has them, are set with chown before the mode, because chown clears
            the setuid and setgid bits. Paths that do not exist are skipped. Symbolic links
            are skipped with a warning, because chown and chmod would change the file the
            link points at.

            Requires root. Supports -WhatIf and -Confirm. Linux only.

        .PARAMETER LiteralPath
            A .psd1 rule file to apply instead of Config/LinuxFilePermission.psd1. It must
            hold a Rule list of hashtables with Path, Mode, and optionally Owner and Group.

        .PARAMETER PassThru
            Returns each path that was changed.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.IO.FileSystemInfo. With -PassThru, one object per changed path.
            Otherwise nothing.

        .EXAMPLE
            Set-LinuxFilePermission -WhatIf

            Lists each path that would change, with its owner and mode before and after.

        .EXAMPLE
            Invoke-Sudo { Import-Module ./PSSecurity.psd1; Set-LinuxFilePermission -PassThru }

            Applies the rules as root and lists the paths that changed.

        .EXAMPLE
            Set-LinuxFilePermission -LiteralPath ./MyPermission.psd1

            Applies a custom rule file.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([System.IO.FileSystemInfo])]
        param(
            [Parameter(HelpMessage = 'Enter a .psd1 rule file to apply instead of Config/LinuxFilePermission.psd1.')]
            [ValidateNotNullOrEmpty()]
            [string]$LiteralPath,

            [Parameter(HelpMessage = 'Return each path that was changed.')]
            [switch]$PassThru
        )

        if (-not $PSBoundParameters.ContainsKey('LiteralPath')) {
            $LiteralPath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Config' -AdditionalChildPath 'LinuxFilePermission.psd1'
        }
        $rules = (Import-PowerShellDataFile -LiteralPath $LiteralPath).Rule

        foreach ($rule in $rules) {
            $floor = [System.IO.UnixFileMode][System.Convert]::ToInt32($rule.Mode, 8)
            $hasOwner = $rule.ContainsKey('Owner')

            foreach ($item in Get-Item -Path $rule.Path -Force -ErrorAction Ignore) {
                if ($item.LinkType) {
                    Write-Warning -Message "Skipped $($item.FullName): it is a $($item.LinkType) to $($item.Target)."
                    continue
                }

                $newMode = $item.UnixFileMode -band $floor
                $needsOwner = $hasOwner -and ($item.User -ne $rule.Owner -or $item.Group -ne $rule.Group)
                $needsMode = $newMode -ne $item.UnixFileMode
                if (-not ($needsOwner -or $needsMode)) {
                    Write-Verbose -Message "$($item.FullName) already complies."
                    continue
                }

                $owner = if ($needsOwner) { "$($rule.Owner):$($rule.Group)" } else { "$($item.User):$($item.Group)" }
                $oldOctal = [System.Convert]::ToString([int]$item.UnixFileMode, 8)
                $newOctal = [System.Convert]::ToString([int]$newMode, 8)
                $change = "Set $owner $newOctal, was $($item.User):$($item.Group) $oldOctal"

                if ($PSCmdlet.ShouldProcess($item.FullName, $change)) {
                    if ($needsOwner) {
                        (chown -- $owner $item.FullName)
                        if ($LASTEXITCODE -ne 0) {
                            throw "Set-LinuxFilePermission failed to change the owner of $($item.FullName) to $owner."
                        }
                    }
                    [System.IO.File]::SetUnixFileMode($item.FullName, $newMode)

                    if ($PassThru) {
                        Get-Item -LiteralPath $item.FullName -Force
                    }
                }
            }
        }
    }
}
