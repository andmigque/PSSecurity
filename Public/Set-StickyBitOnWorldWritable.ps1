# if ($IsLinux) {
#     Set-StrictMode -Version Latest

#     function Set-StickyBitOnWorldWritable {
#         <#
#     .SYNOPSIS
#         Adds the sticky bit to world-writable Linux directories.

#     .DESCRIPTION
#         Walks Path with a directory stack. Symlinks, nested mounts, and excluded
#         directory prefixes are skipped before descent. Every world-writable directory
#         without the sticky bit keeps its existing permissions and gains the sticky bit.
#         The changed mode is read back to verify the repair. Implements CIS 1.1.21 for
#         the selected filesystem; run separately for other local filesystems.
#         Progress shows directories scanned, repairs, errors, and the current path.
#         The scan has no percentage because the directory count is not known upfront.
#         Access-denied failures produce one warning recommending -Elevate when the
#         session is not root. Detailed failures remain in Errors.

#     .PARAMETER Path
#         Directory to scan. Defaults to /. Large trees can take several minutes.

#     .PARAMETER ExcludePath
#         Literal directory prefixes to skip. Defaults to StickyBitExcludePath in
#         Config/Setting.psd1. /proc, /sys, /dev, and /run are always excluded.

#     .PARAMETER Elevate
#         Runs the function as root through the module's existing sudo helper.
#         sudo may prompt for a password. Preserves -WhatIf and -Confirm.

#     .OUTPUTS
#         One summary with Path, TotalDirectories, HardenedDirectories,
#         FailedDirectories, and Errors. TotalDirectories counts directories needing
#         repair. FailedDirectories includes traversal and repair failures. Errors
#         contains Path and Message. Declined changes are not counted as hardened.

#     .EXAMPLE
#         Set-StickyBitOnWorldWritable -Path /var -WhatIf

#     .EXAMPLE
#         Set-StickyBitOnWorldWritable -Elevate
#     #>
#         [CmdletBinding(SupportsShouldProcess)]
#         [OutputType([pscustomobject])]
#         param(
#             [Parameter(HelpMessage = 'Enter the directory to scan.')]
#             [ValidateNotNullOrEmpty()]
#             [string]$Path = '/',

#             [Parameter(HelpMessage = 'Enter literal directory prefixes to exclude.')]
#             [string[]]$ExcludePath = $script:StickyBitExcludePath,

#             [Parameter(HelpMessage = 'Run as root through sudo.')]
#             [switch]$Elevate
#         )

#         $Path = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).ProviderPath
#         $sessionIsRoot = (& id -u) -eq 0

#         if ($Elevate -and -not $sessionIsRoot) {
#             $excludeArgument = (@($ExcludePath | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ',')
#             if (-not $excludeArgument) {
#                 $excludeArgument = '@()'
#             }
#             $command = "Set-StickyBitOnWorldWritable -Path '$($Path.Replace("'", "''"))' -ExcludePath $excludeArgument"
#             if ($WhatIfPreference) { $command += ' -WhatIf' }
#             if ($PSBoundParameters.ContainsKey('Confirm')) { $command += ' -Confirm:$' + [string][bool]$PSBoundParameters['Confirm'] }
#             Invoke-SudoCommand -Command $command
#             return
#         }

#         $excludedDirectories = @('/proc', '/sys', '/dev', '/run')
#         foreach ($excludedPath in $ExcludePath) {
#             $excludedDirectories += [System.IO.Path]::GetFullPath($excludedPath).TrimEnd('/')
#         }

#         $mountPoints = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
#         foreach ($line in Get-Content -LiteralPath '/proc/mounts' -ErrorAction Stop) {
#             $fields = $line -split ' '
#             $mountPath = $fields[1].Replace('\040', ' ').Replace('\011', "`t").Replace('\012', "`n").Replace('\134', '\')
#             [void]$mountPoints.Add($mountPath)
#         }

#         $directories = [System.Collections.Generic.Stack[string]]::new()
#         $directories.Push($Path)
#         $errors = [System.Collections.Generic.List[object]]::new()
#         $totalDirectories = 0
#         $hardenedDirectories = 0
#         $scannedDirectories = 0
#         $accessDeniedDirectories = 0
#         $progressTimer = [System.Diagnostics.Stopwatch]::StartNew()

#         try {
#             Write-Progress -Id 0 -Activity 'Hardening world-writable directories' -Status 'Discovering directories' -PercentComplete -1

#             while ($directories.Count -gt 0) {
#                 $directoryPath = $directories.Pop()

#                 if ($progressTimer.ElapsedMilliseconds -ge 200) {
#                     $status = '{0} scanned; {1} need repair; {2} hardened; {3} errors' -f `
#                         $scannedDirectories, $totalDirectories, $hardenedDirectories, $errors.Count
#                     Write-Progress -Id 0 -Activity 'Hardening world-writable directories' `
#                         -Status $status -CurrentOperation $directoryPath -PercentComplete -1
#                     $progressTimer.Restart()
#                 }

#                 $isExcluded = $false
#                 foreach ($excludedPath in $excludedDirectories) {
#                     if ($directoryPath -ceq $excludedPath -or $directoryPath.StartsWith("$excludedPath/", [StringComparison]::Ordinal)) {
#                         $isExcluded = $true
#                         break
#                     }
#                 }
#                 if ($isExcluded) { continue }

#                 $repairInProgress = $false
#                 try {
#                     $directory = Get-Item -LiteralPath $directoryPath -Force -ErrorAction Stop
#                     if (-not $directory.PSIsContainer) { throw 'Path is not a directory.' }
#                     if ($directory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
#                     $scannedDirectories++

#                     foreach ($child in Get-ChildItem -LiteralPath $directoryPath -Directory -Force -ErrorAction Stop) {
#                         if (-not $mountPoints.Contains($child.FullName)) {
#                             $directories.Push($child.FullName)
#                         }
#                         if ($progressTimer.ElapsedMilliseconds -ge 200) {
#                             $status = '{0} scanned; {1} need repair; {2} hardened; {3} errors' -f `
#                                 $scannedDirectories, $totalDirectories, $hardenedDirectories, $errors.Count
#                             Write-Progress -Id 0 -Activity 'Hardening world-writable directories' `
#                                 -Status $status -CurrentOperation $directoryPath -PercentComplete -1
#                             $progressTimer.Restart()
#                         }
#                     }

#                     $mode = [System.IO.File]::GetUnixFileMode($directoryPath)
#                     $worldWritable = [bool]($mode -band [System.IO.UnixFileMode]::OtherWrite)
#                     $hasStickyBit = [bool]($mode -band [System.IO.UnixFileMode]::StickyBit)
#                     if (-not $worldWritable -or $hasStickyBit) { continue }

#                     $totalDirectories++
#                     if ($PSCmdlet.ShouldProcess($directoryPath, 'Add sticky bit')) {
#                         $repairInProgress = $true
#                         Write-Progress -Id 1 -ParentId 0 -Activity $directoryPath `
#                             -Status 'Setting and verifying sticky bit' -PercentComplete -1
#                         $targetMode = $mode -bor [System.IO.UnixFileMode]::StickyBit
#                         [System.IO.File]::SetUnixFileMode($directoryPath, $targetMode)
#                         $afterMode = [System.IO.File]::GetUnixFileMode($directoryPath)
#                         if ($afterMode -ne $targetMode) { throw 'Directory mode did not match after the change.' }
#                         $hardenedDirectories++
#                     }
#                 }
#                 catch {
#                     $exception = $_.Exception
#                     while ($null -ne $exception) {
#                         if ($exception -is [System.UnauthorizedAccessException]) {
#                             $accessDeniedDirectories++
#                             break
#                         }
#                         $exception = $exception.InnerException
#                     }
#                     $errors.Add([pscustomobject]@{ Path = $directoryPath; Message = $_.Exception.Message })
#                 }
#                 finally {
#                     if ($repairInProgress) {
#                         Write-Progress -Id 1 -Activity 'Setting sticky bit' -Completed
#                     }
#                 }
#             }
#         }
#         finally {
#             Write-Progress -Id 1 -Activity 'Setting sticky bit' -Completed
#             Write-Progress -Id 0 -Activity 'Hardening world-writable directories' -Completed
#         }

#         if ($accessDeniedDirectories -gt 0) {
#             $warning = "Access was denied for $accessDeniedDirectories directories; some paths could not be scanned or repaired."
#             if (-not $sessionIsRoot) {
#                 $warning += ' Run Set-StickyBitOnWorldWritable with -Elevate to retry as root.'
#             }
#             Write-Warning -Message $warning
#         }

#         [pscustomobject]@{
#             Path                = $Path
#             TotalDirectories    = $totalDirectories
#             HardenedDirectories = $hardenedDirectories
#             FailedDirectories   = $errors.Count
#             Errors              = $errors.ToArray()
#         }
#     }
# }
