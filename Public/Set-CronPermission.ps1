

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Set-CronPermission</h2>
####
function Set-CronPermission {
    #### Restrict all standard cron directories to 700 via `sudo chmod`.
    ####
    #### A world readable cron directory lets any local account read what runs
    #### as root and when. A writable one lets them change it.
    ####
    #### Supports `-WhatIf`.
    ####
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $CronDirectories = @('/etc/cron.d', '/etc/cron.daily', '/etc/cron.hourly', '/etc/cron.weekly', '/etc/cron.monthly')

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[string]`
    ####     - *One line per directory that was changed.*
    ####     - *A warning naming any directory that does not exist.*
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
####
#### ---
####

