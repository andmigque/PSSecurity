# if ($IsLinux) {
#     Set-StrictMode -Version Latest

#     function Set-ModprobeBlacklist {
#         <#
#     .SYNOPSIS
#         Writes the module's CIS kernel module blacklist table on Linux.

#     .DESCRIPTION
#         Writes one managed file in /etc/modprobe.d so the kernel refuses to load every
#         module in the table. This covers the CIS Distribution Independent Linux controls
#         for unused filesystems, USB storage, and uncommon network protocols. The
#         filesystem list is cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs, and udf, and
#         the protocol list is dccp, sctp, rds, and tipc. Each rule is the install
#         directive the benchmark remediation asks for, for example install cramfs
#         /bin/true.

#         The file is rewritten on every run so it always mirrors the table, and the 99-
#         prefix keeps it ahead of distribution defaults in the modprobe.d load order.
#         Modules that are currently loaded keep running until they are unloaded or the
#         system reboots; the report marks those rows as Loaded instead of unloading them,
#         because removing a module from a running kernel can disrupt live services.

#         A non-root session writes the file through sudo, which may prompt for a password.

#     .PARAMETER Table
#         The modules to blacklist, each entry a hashtable with Module and Purpose. Defaults
#         to the module's ModprobeBlacklist setting from Config/Setting.psd1.

#     .PARAMETER Path
#         The modprobe.d configuration file to write. Defaults to
#         /etc/modprobe.d/99-pssecurity-blacklist.conf.

#     .INPUTS
#         None. This function does not accept pipeline input.

#     .OUTPUTS
#         One PSCustomObject per module with Module, Loaded, Before, After, and Status.
#         Before and After carry the actual modprobe rule line, for example install cramfs
#         /bin/true, with Before reading Absent when the file held no rule for the module.
#         Status is Compliant when the rule was already configured and the module is not
#         loaded, Preview under -WhatIf, Hardened when this run added the rule and the
#         module is not loaded, Loaded when the module is currently loaded so the rule takes
#         effect only after an unload or reboot, and Failed when the write or the
#         verification failed. When the file is written, one string summarizes the run with
#         the file it wrote and how many listed modules are currently loaded.

#     .EXAMPLE
#         Set-ModprobeBlacklist -WhatIf

#         Previews the blacklist file the table would write without touching the system.

#     .EXAMPLE
#         Set-ModprobeBlacklist

#         Writes /etc/modprobe.d/99-pssecurity-blacklist.conf for every module in the table.

#     .NOTES
#         Runs on Linux only; in WSL, run it inside the target distribution. The default
#         table comes from the ModprobeBlacklist key in Config/Setting.psd1. Blacklisting
#         usb-storage blocks USB mass storage, so remove that entry for hosts that need it.
#     #>
#         [CmdletBinding(SupportsShouldProcess)]
#         [OutputType([pscustomobject], [string])]
#         param (
#             # Modules to blacklist. Defaults to the module's ModprobeBlacklist setting.
#             [Parameter(HelpMessage = 'Enter a table of Module and Purpose entries. Defaults to the ModprobeBlacklist setting.')]
#             [ValidateNotNullOrEmpty()]
#             [hashtable[]]$Table = $script:ModprobeBlacklist,

#             # The modprobe.d configuration file to write.
#             [Parameter(HelpMessage = 'Enter the modprobe.d configuration file to write.')]
#             [ValidateNotNullOrEmpty()]
#             [string]$Path = '/etc/modprobe.d/99-pssecurity-blacklist.conf'
#         )

#         $sessionIsRoot = (& id -u) -eq 0

#         if (-not $sessionIsRoot -and -not $WhatIfPreference -and -not (Get-Command -Name sudo -ErrorAction SilentlyContinue)) {
#             throw 'sudo was not found on this system. Run as root instead.'
#         }

#         # lsmod reports module names with underscores where the table may use dashes.
#         $loadedModules = $null
#         if (Get-Command -Name lsmod -ErrorAction SilentlyContinue) {
#             $lsmodOutput = @(& lsmod 2>$null)

#             if ($LASTEXITCODE -eq 0) {
#                 $loadedModules = @($lsmodOutput | Select-Object -Skip 1 | ForEach-Object { ($_ -split '\s+')[0] })
#             }
#         }
#         else {
#             Write-Error -Message 'lsmod was not found; the loaded module state cannot be verified.'
#         }

#         $beforeLines = @()
#         if (Test-Path -LiteralPath $Path -PathType Leaf) {
#             $beforeLines = @(Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue)
#         }

#         $newLines = [System.Collections.Generic.List[string]]::new()
#         [void]$newLines.Add('# Managed by PSSecurity Set-ModprobeBlacklist. Rewritten on every run.')

#         foreach ($entry in $Table) {
#             $module = [string]$entry['Module']

#             if (-not $module -or $module -notmatch '^[A-Za-z][A-Za-z0-9_-]*$') {
#                 Write-Error -Message "Invalid table entry: '$module'."
#                 continue
#             }

#             [void]$newLines.Add("install $module /bin/true")
#         }

#         $applied = $false
#         $declined = $false

#         if ($PSCmdlet.ShouldProcess($Path, 'Write kernel module blacklist file')) {
#             try {
#                 if ($sessionIsRoot) {
#                     $newLines | Set-Content -LiteralPath $Path -ErrorAction Stop
#                     $applied = $true
#                 }
#                 else {
#                     $newLines | sudo tee -- $Path | Out-Null
#                     $applied = ($LASTEXITCODE -eq 0)
#                 }
#             }
#             catch {
#                 $applied = $false
#             }

#             if (-not $applied) {
#                 Write-Error -Message "Could not write the blacklist file to $Path."
#             }
#         }
#         else {
#             $declined = $true
#         }

#         $verifiedLines = $beforeLines
#         if ($applied) {
#             $verifiedLines = @(Get-Content -LiteralPath $Path -ErrorAction SilentlyContinue)
#         }

#         $loadedCount = 0

#         foreach ($entry in $Table) {
#             $module = [string]$entry['Module']

#             if (-not $module -or $module -notmatch '^[A-Za-z][A-Za-z0-9_-]*$') {
#                 continue
#             }

#             $rule = "install $module /bin/true"
#             $rulePattern = '^\s*install\s+{0}\s+(\S+)\s*$' -f [regex]::Escape($module)
#             $beforeRule = $null

#             foreach ($line in $beforeLines) {
#                 if ($line -match $rulePattern) {
#                     $beforeRule = "install $module $($Matches[1])"
#                     break
#                 }
#             }

#             $wasConfigured = ($beforeRule -eq $rule)
#             $isConfigured = $verifiedLines -contains $rule
#             $normalized = $module.Replace('-', '_')
#             $isLoaded = ($null -ne $loadedModules) -and ($loadedModules -contains $normalized)

#             if ($isLoaded) {
#                 $loadedCount++
#             }

#             if ($wasConfigured -and -not $isLoaded) {
#                 $status = 'Compliant'
#             }
#             elseif ($declined) {
#                 $status = 'Preview'
#             }
#             elseif ($isLoaded) {
#                 $status = 'Loaded'
#             }
#             elseif ($applied -and $isConfigured) {
#                 $status = 'Hardened'
#             }
#             else {
#                 $status = 'Failed'
#             }

#             $before = if ($beforeRule) { $beforeRule } else { 'Absent' }
#             $after = if ($isConfigured) { $rule } else { $before }

#             [PSCustomObject]@{ Module = $module; Loaded = $isLoaded; Before = $before; After = $after; Status = $status }
#         }

#         if ($applied) {
#             $ruleCount = $newLines.Count - 1
#             $loadedNote = if ($loadedCount -gt 0) {
#                 "$loadedCount listed modules are loaded; their rules apply after unload or reboot."
#             }
#             else {
#                 'No listed modules are currently loaded.'
#             }

#             Write-Output "Wrote $ruleCount module rules to $Path. $loadedNote"
#         }
#     }
# }
