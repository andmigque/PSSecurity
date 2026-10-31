# #!/usr/bin/env pwsh
# Set-StrictMode -Version Latest

# if ($IsLinux) {
#     function Set-CronPermission {
#         <#
#         .SYNOPSIS
#             Restricts the standard cron directories to root.

#         .DESCRIPTION
#             Sets each cron directory to owner root, group root, and mode 0700 or stricter
#             through Set-LinuxFilePermission. Only the directories change; the scripts inside
#             keep their modes. Implements CIS 5.1.3 through 5.1.7.

#         .PARAMETER Path
#             The cron directories to restrict.

#         .INPUTS
#             None. This function does not accept pipeline input.

#         .OUTPUTS
#             System.Management.Automation.PSCustomObject. Path, Before, After, and Status for
#             each directory, as returned by Set-LinuxFilePermission.

#         .EXAMPLE
#             Set-CronPermission -WhatIf

#             Previews the changes to cron.d, cron.daily, cron.hourly, cron.weekly, and cron.monthly.

#         .EXAMPLE
#             Invoke-Sudo { Import-Module PSSecurity; Set-CronPermission }

#             Restricts the cron directories as root.

#         .NOTES
#             Run as root. Directories absent on this distribution report Missing.
#         #>
#         [CmdletBinding(SupportsShouldProcess)]
#         [OutputType([pscustomobject])]
#         param(
#             [Parameter(HelpMessage = 'Enter the cron directories to restrict.')]
#             [ValidateNotNullOrEmpty()]
#             [string[]]$Path = @('/etc/cron.d', '/etc/cron.daily', '/etc/cron.hourly', '/etc/cron.weekly', '/etc/cron.monthly')
#         )

#         # Only the directories change. A recursive chmod 700 sets the execute bit on every
#         # file inside, and run-parts runs every executable file in cron.daily and its
#         # siblings, so a job disabled with chmod -x would start running again.
#         $table = foreach ($directory in $Path) {
#             @{ Path = $directory; Owner = 'root'; Group = 'root'; Mode = '0700' }
#         }

#         # -WhatIf and -Confirm reach Set-LinuxFilePermission through $WhatIfPreference and
#         # $ConfirmPreference, which a function in the same module inherits from this scope.
#         Set-LinuxFilePermission -Table $table
#     }
# }
