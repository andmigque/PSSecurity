#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Add-UnixFileMode {
        <#
        .SYNOPSIS
            Adds bits to the Unix mode of files or directories.

        .DESCRIPTION
            Adds the -Mode bits to each item's existing UnixFileMode, the same as chmod
            with +. Bits already set are kept, and items that already have every bit are
            left unchanged. Takes items from Get-UnixFileMode, Get-ChildItem, or Get-Item,
            or paths.

            Changing an item you don't own requires root. Supports -WhatIf and -Confirm.
            Linux only.

        .PARAMETER LiteralPath
            The path of the item to change, used exactly as typed. Accepts paths, and
            items with a FullName property, from the pipeline.

        .PARAMETER Mode
            The mode bits to add, such as StickyBit or GroupRead.

        .PARAMETER PassThru
            Returns each item after the change.

        .INPUTS
            System.String, System.IO.FileSystemInfo. You can pipe paths or file system
            items to this function.

        .OUTPUTS
            System.IO.FileSystemInfo. With -PassThru, one object per item. Otherwise
            nothing.

        .EXAMPLE
            Get-UnixFileMode -Path / -Mode OtherWrite -ItemType Directory | Add-UnixFileMode -Mode StickyBit -WhatIf

            Lists the world-writable directories that would gain the sticky bit (CIS
            1.1.21), with each mode before and after, without changing them.

        .EXAMPLE
            Add-UnixFileMode -LiteralPath /srv/share -Mode StickyBit -PassThru | Select-Object FullName, UnixFileMode

            Adds the sticky bit to /srv/share and shows its new mode.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([System.IO.FileSystemInfo])]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName,
                HelpMessage = 'Enter the path of the item to change. Accepts paths and items from the pipeline.')]
            [Alias('FullName')]
            [ValidateNotNullOrEmpty()]
            [string]$LiteralPath,

            [Parameter(Mandatory, HelpMessage = 'Enter the mode bits to add, such as StickyBit.')]
            [System.IO.UnixFileMode]$Mode,

            [Parameter(HelpMessage = 'Return each item after the change.')]
            [switch]$PassThru
        )
        process {
            $item = Get-Item -LiteralPath $LiteralPath -Force -ErrorAction Stop
            $oldMode = $item.UnixFileMode
            $newMode = $oldMode -bor $Mode

            # Octal, as chmod and ls -l users read modes.
            $oldOctal = [System.Convert]::ToString([int]$oldMode, 8)
            $newOctal = [System.Convert]::ToString([int]$newMode, 8)
            $change = "Change mode from $oldOctal to $newOctal"
            if ($newMode -ne $oldMode -and $PSCmdlet.ShouldProcess($item.FullName, $change)) {
                $item.UnixFileMode = $newMode
            }

            if ($PassThru) {
                $item.Refresh()
                $item
            }
        }
    }
}
