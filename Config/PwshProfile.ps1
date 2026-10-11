#!/usr/bin/env pwsh
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
Set-StrictMode -Version 3.0
Set-Variable -Name 'POWERSHELL_TELEMETRY_OPTOUT' -Value 'true'
# Check for interactive mode
$IsInteractive = $Host.Name -eq 'ConsoleHost' -and $Host.UI -and $Host.UI.RawUI -and [Environment]::UserInteractive
$HasConsole = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected

$envHome = [string]::IsNullOrEmpty($($env:USERPROFILE)) ? $HOME : (Resolve-Path('~')).Path

if ($IsInteractive -and $HasConsole -and (Get-Module -Name PSReadLine -ListAvailable)) {
    Import-Module PSReadLine -MinimumVersion '2.4.5'

    $psHistoryLog = Join-Path $envHome 'pshistory.log'
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistoryNoDuplicates -EditMode Windows -HistorySaveStyle SaveIncrementally -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistorySavePath $psHistoryLog
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}

function prompt {
    $gitBranch = (Test-Path './.git') ? ((Get-Content '.git/HEAD').replace('ref: refs/heads/', '')) : '👎'
        $shortTime = (Get-Date).ToShortTimeString()
    "`e[1m`e[94m╭PS`e[0m 🦾( ͡⚈ ʖ ͡⚈)🤳`e[1m`e[35m[$gitBranch]`e[0m`e[4m$($executionContext.SessionState.Path.CurrentLocation)`e[36m 🕒 $shortTime`e[0m`
`e[94m╰┈➤`e[0m$(' ' * ($nestedPromptLevel + 1)) "
}
