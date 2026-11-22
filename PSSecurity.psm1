Set-StrictMode -Version Latest

if ($null -eq (Get-Variable -Name PSSecurityThreadPool -Scope Global -ErrorAction Ignore)) {
    $global:PSSecurityThreadPool = [PSCustomObject]@{}
}

$env:POWERSHELL_TELEMETRY_OPTOUT = 'true'
$root = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

$script:SettingsPath = Join-Path -Path $root -ChildPath 'Config' -AdditionalChildPath 'Setting.psd1'
$psSecuritySettings = Import-PowerShellDataFile -LiteralPath $script:SettingsPath

$script:HashIndexAlgorithm = $psSecuritySettings.HashIndexAlgorithm
$script:HashIndexInclude = $psSecuritySettings.HashIndexInclude
$script:HashIndexExclude = $psSecuritySettings.HashIndexExclude

$script:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$script:IsInteractive = $Host.Name -eq 'ConsoleHost' -and $Host.UI -and $Host.UI.RawUI -and [Environment]::UserInteractive

$script:HasConsole = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected

Get-ChildItem -Path "$(Join-Path -Path $root -ChildPath 'Private')" -Filter '*.ps1' | Resolve-Path | ForEach-Object { . $_ }
$sysFuncs = Get-ChildItem Function:
Get-ChildItem -Path "$(Join-Path -Path $root -ChildPath 'Public')" -Filter '*.ps1' | Resolve-Path | ForEach-Object { . $_ }
$funcs = Get-ChildItem Function: | Where-Object { $sysFuncs -notcontains $_ }

if ($funcs) {
    Export-ModuleMember -Function $funcs.Name
}
else {
    throw 'PSSecurity function load failed. Check module .psd1'
}
