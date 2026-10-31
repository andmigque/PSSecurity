# #!/usr/bin/env pwsh
# Set-StrictMode -Version Latest

# if ($IsLinux) {
#     function Set-HomeDirectoryPermission {
#         <#
#         .SYNOPSIS
#             Restricts the modes of user home directories and /root.

#         .DESCRIPTION
#             Tightens every directory directly under HomePath to Mode and /root to RootMode
#             through Set-LinuxFilePermission. Both modes are floors: a home already more
#             restrictive keeps its mode, and a looser home loses only the excess bits.
#             Ownership never changes, and files inside each home keep their modes.
#             Implements CIS 6.2.x home directory permissions.

#         .PARAMETER Mode
#             The octal floor for directories under HomePath.

#         .PARAMETER RootMode
#             The octal floor for /root.

#         .PARAMETER HomePath
#             The parent directory of user home directories.

#         .PARAMETER Exclude
#             Home directory names to skip. Wildcards are allowed, for example shared*.

#         .INPUTS
#             None. This function does not accept pipeline input.

#         .OUTPUTS
#             System.Management.Automation.PSCustomObject. Path, Before, After, and Status for
#             each directory, as returned by Set-LinuxFilePermission.

#         .EXAMPLE
#             Set-HomeDirectoryPermission -WhatIf

#             Previews the changes for every home directory and /root.

#         .EXAMPLE
#             Invoke-Sudo { Import-Module PSSecurity; Set-HomeDirectoryPermission -Exclude 'shared*' }

#             Tightens every home directory except those matching shared*, and /root, as root.

#         .NOTES
#             Run as root.
#         #>
#         [CmdletBinding(SupportsShouldProcess)]
#         [OutputType([pscustomobject])]
#         param(
#             [Parameter(HelpMessage = 'Enter the octal floor for home directories, such as 0750.')]
#             [ValidatePattern('^[0-7]{3,4}$', ErrorMessage = 'Mode must be an octal value such as 750 or 0750.')]
#             [string]$Mode = '0750',

#             [Parameter(HelpMessage = 'Enter the octal floor for /root, such as 0700.')]
#             [ValidatePattern('^[0-7]{3,4}$', ErrorMessage = 'RootMode must be an octal value such as 700 or 0700.')]
#             [string]$RootMode = '0700',

#             [Parameter(HelpMessage = 'Enter the parent directory of user home directories.')]
#             [ValidateNotNullOrEmpty()]
#             [string]$HomePath = '/home',

#             [Parameter(HelpMessage = 'Enter home directory names to skip. Wildcards are allowed.')]
#             [string[]]$Exclude = @()
#         )

#         $table = [System.Collections.Generic.List[hashtable]]::new()

#         # -Force includes home directories whose names start with a dot.
#         foreach ($homeDirectory in Get-ChildItem -LiteralPath $HomePath -Directory -Force -ErrorAction Stop) {
#             # A symlink here points outside HomePath, and chmod follows symlinks, so the
#             # change would land on the link's target.
#             if ($homeDirectory.LinkType) {
#                 Write-Verbose -Message "Skipping symbolic link: $($homeDirectory.FullName)"
#                 continue
#             }

#             if (@($Exclude).Where({ $homeDirectory.Name -like $_ })) {
#                 Write-Verbose -Message "Skipping excluded home directory: $($homeDirectory.FullName)"
#                 continue
#             }

#             # No Owner or Group, so Set-LinuxFilePermission leaves ownership alone. Each home
#             # belongs to its user, and this function only tightens the mode.
#             $table.Add(@{ Path = $homeDirectory.FullName; Mode = $Mode })
#         }

#         $table.Add(@{ Path = '/root'; Mode = $RootMode })

#         # -WhatIf and -Confirm reach Set-LinuxFilePermission through $WhatIfPreference and
#         # $ConfirmPreference, which a function in the same module inherits from this scope.
#         Set-LinuxFilePermission -Table $table.ToArray()
#     }
# }
