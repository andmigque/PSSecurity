# #!/usr/bin/env pwsh
# Set-StrictMode -Version Latest

# if ($IsLinux) {
#     function Set-LinuxFilePermission {
#         <#
#         .SYNOPSIS
#             Applies the CIS ownership and mode table to Linux system files.

#         .DESCRIPTION
#             Reads the owner, group, and mode of every path in the table and tightens it to
#             the table's floor. The mode is a floor: a path already more restrictive keeps its
#             mode, and a path granting more access loses only the excess bits, so a repair
#             never grants access the path did not already have. The table group and the
#             table owner are both accepted as the group, which covers the shadow files that
#             CIS allows as root or shadow. Every change is read back to verify it. The only
#             external tools are the POSIX chown and chgrp.

#             Owner and Group are optional per entry. An entry without them changes the mode
#             only and leaves ownership alone.

#         .PARAMETER Table
#             The paths to repair, each a hashtable with Path, Mode, and optional Owner and
#             Group. Defaults to the module's LinuxFilePermissions setting.

#         .INPUTS
#             None. This function does not accept pipeline input.

#         .OUTPUTS
#             System.Management.Automation.PSCustomObject. Path, Before, After, and Status for
#             each entry. Before and After read like root:shadow 0640. Status is Compliant,
#             Preview, Hardened, Failed, or Missing.

#         .EXAMPLE
#             Set-LinuxFilePermission -WhatIf

#             Previews the repairs for every path in the table.

#         .EXAMPLE
#             Invoke-Sudo { Import-Module PSSecurity; Set-LinuxFilePermission }

#             Repairs every path in the table as root.

#         .NOTES
#             Run as root. Requires PowerShell 7.3 or later for the UnixStat property. Paths in
#             the table that do not exist on this distribution report Missing, so one table
#             works across distributions. An owner or group with no account name reports its
#             numeric ID.
#         #>
#         [CmdletBinding(SupportsShouldProcess)]
#         [OutputType([pscustomobject])]
#         param(
#             [Parameter(HelpMessage = 'Enter Path, Mode, and optional Owner and Group entries.')]
#             [ValidateNotNullOrEmpty()]
#             [hashtable[]]$Table = $script:LinuxFilePermissions
#         )

#         # UnixStat is PowerShell's own lstat data, so reading owner, group, and mode needs
#         # no stat binary, whose flags differ between GNU coreutils and BusyBox. User and
#         # Group are empty when the ID has no account, so the numeric ID stands in.
#         # 4095 is octal 7777: the permission bits plus SUID, SGID, and sticky, without the
#         # file type bits.
#         $readState = {
#             param([string]$StatPath)
#             $statItem = Get-Item -LiteralPath $StatPath -Force -ErrorAction Stop
#             [pscustomobject]@{
#                 Owner = if ($statItem.User) { $statItem.User } else { [string]$statItem.UnixStat.UserId }
#                 Group = if ($statItem.Group) { $statItem.Group } else { [string]$statItem.UnixStat.GroupId }
#                 Mode  = $statItem.UnixStat.Mode -band 4095
#             }
#         }

#         $formatState = {
#             param($State)
#             '{0}:{1} {2}' -f $State.Owner, $State.Group, [Convert]::ToString($State.Mode, 8).PadLeft(4, '0')
#         }

#         foreach ($entry in $Table) {
#             $targetPath = [string]$entry['Path']
#             $owner = [string]$entry['Owner']
#             $group = [string]$entry['Group']
#             $mode = [string]$entry['Mode']

#             if (-not $targetPath -or $mode -notmatch '^[0-7]{3,4}$') {
#                 Write-Error -Message "Invalid table entry for '$targetPath'."
#                 continue
#             }

#             $result = [pscustomobject]@{ Path = $targetPath; Before = $null; After = $null; Status = 'Missing' }

#             try {
#                 $item = Get-Item -LiteralPath $targetPath -Force -ErrorAction Ignore
#                 if (-not $item) {
#                     $result
#                     continue
#                 }

#                 # chown and chmod follow symlinks, so a link in the table would hand root's
#                 # repair to whatever file the link points at.
#                 if ($item.LinkType) {
#                     throw "$targetPath is a symbolic link."
#                 }

#                 $current = & $readState $targetPath
#                 $result.Before = & $formatState $current

#                 # current AND floor keeps only the bits the floor allows. Setting the floor
#                 # directly would add bits: a 0602 file with a 0640 floor would gain group read.
#                 $floor = [Convert]::ToInt32($mode, 8)
#                 $planned = [pscustomobject]@{
#                     Owner = if ($owner) { $owner } else { $current.Owner }
#                     Group = $current.Group
#                     Mode  = $current.Mode -band $floor
#                 }

#                 $needsOwner = $owner -and $current.Owner -ne $owner
#                 $needsGroup = $group -and $current.Group -notin @($owner, $group)
#                 $needsMode = $planned.Mode -ne $current.Mode
#                 if ($needsGroup) { $planned.Group = $group }

#                 $result.After = & $formatState $planned

#                 if (-not ($needsOwner -or $needsGroup -or $needsMode)) {
#                     $result.Status = 'Compliant'
#                     $result
#                     continue
#                 }

#                 if (-not $PSCmdlet.ShouldProcess($targetPath, "Set owner, group, and mode to $($result.After)")) {
#                     $result.Status = 'Preview'
#                     $result
#                     continue
#                 }

#                 # Ownership changes run before the mode change because chown and chgrp clear
#                 # the setuid and setgid bits, which would undo a mode set first. chown
#                 # owner:group and chgrp group are both POSIX; the ':group' shorthand for
#                 # chown is not, so a group-only change goes through chgrp.
#                 if ($needsOwner) {
#                     $chownSpec = if ($needsGroup) { "${owner}:$group" } else { $owner }
#                     chown -- $chownSpec $targetPath
#                     if ($LASTEXITCODE -ne 0) { throw "chown failed for $targetPath." }
#                 }
#                 elseif ($needsGroup) {
#                     chgrp -- $group $targetPath
#                     if ($LASTEXITCODE -ne 0) { throw "chgrp failed for $targetPath." }
#                 }

#                 if ($needsMode) {
#                     [System.IO.File]::SetUnixFileMode($targetPath, [System.IO.UnixFileMode]$planned.Mode)
#                 }

#                 $verified = & $formatState (& $readState $targetPath)
#                 if ($verified -ne $result.After) {
#                     $result.After = $verified
#                     throw "$targetPath reads $verified after the change."
#                 }

#                 $result.Status = 'Hardened'
#                 $result
#             }
#             catch {
#                 $result.Status = 'Failed'
#                 $result
#                 Write-Error -ErrorRecord $_
#             }
#         }
#     }
# }
