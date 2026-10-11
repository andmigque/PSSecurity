

Set-StrictMode -Version Latest

function Set-CronPermission {
    <#
    .SYNOPSIS
        Applies mode 700 recursively to standard cron directories.

    .EXAMPLE
        Set-CronPermission -WhatIf

        Previews permission changes for existing cron.d, daily, hourly, weekly, and monthly directories under /etc. Actual changes use sudo chmod.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $CronDirectories = @('/etc/cron.d', '/etc/cron.daily', '/etc/cron.hourly', '/etc/cron.weekly', '/etc/cron.monthly')

    foreach ($Directory in $CronDirectories) {
        try {
            if (Test-Path -Path $Directory -PathType Container) {
                if ($PSCmdlet.ShouldProcess($Directory, 'Set permissions to 700 recursively')) {
                    & sudo chmod -R 700 -- $Directory
                    Write-Output "Successfully set permissions to 700 for: $Directory"
                }
            }
            else {
                Write-Warning "Directory not found: $Directory"
            }
        }
        catch {
            Write-Error $_
        }
    }
}

