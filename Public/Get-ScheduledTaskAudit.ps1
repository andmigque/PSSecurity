using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Get-ScheduledTaskAudit</h2>
####
function Get-ScheduledTaskAudit {
    #### Return one flat row per scheduled task.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[string]`: __TaskPath__
        ####     - *Task folder to enumerate. Defaults to every folder.*
        [Parameter()][string]$TaskPath = '\*'
    )

    #### Warned, not thrown. Stopping here would deny a non-admin an audit that is
    #### still worth having, but silence would present two thirds of the machine as
    #### the whole of it.
    if (-not (Test-Administrator)) {
        Write-Warning 'Get-ScheduledTaskAudit is not elevated. Enumeration is incomplete and omits SYSTEM context tasks.'
    }

    foreach ($task in Get-ScheduledTask -TaskPath $TaskPath -ErrorAction SilentlyContinue) {

        #### LastRunTime, LastTaskResult and NextRunTime live on a different cmdlet.
        #### Get-ScheduledTask alone never tells you whether a task actually ran.
        $info = $task | Get-ScheduledTaskInfo -ErrorAction SilentlyContinue

        #### A principal is either a UserId or a GroupId, never both. Reading only
        #### UserId leaves every group principal blank, which is a third of the tasks
        #### on a stock Windows install. That failure is silent, unlike the COM action
        #### one above, which is why it is easy to miss.
        $isGroupPrincipal = [string]::IsNullOrWhiteSpace($task.Principal.UserId)
        $principal = if ($isGroupPrincipal) { $task.Principal.GroupId } else { $task.Principal.UserId }

        #### Most non-zero results are not failures. The 0x000413xx range is the
        #### scheduler's own informational set, and "the task has not yet run" alone
        #### accounts for the overwhelming majority of them. The HRESULT severity bit
        #### is what separates a real failure from a status report.
        $resultCode = [uint32]0
        if ($null -ne $info -and $null -ne $info.LastTaskResult) {
            $resultCode = [uint32]($info.LastTaskResult -band 0xFFFFFFFFL)
        }
        $resultKind = if ($resultCode -eq 0) { 'Success' }
        elseif ($resultCode -band 0x80000000) { 'Failure' }
        else { 'Informational' }

        $runs = [System.Collections.Generic.List[string]]::new()
        foreach ($action in @($task.Actions)) {
            switch ($action.CimClass.CimClassName) {
                'MSFT_TaskExecAction' {
                    $runs.Add(($action.Execute, $action.Arguments -join ' ').Trim())
                }
                'MSFT_TaskComHandlerAction' {
                    $runs.Add("COM:$($action.ClassId)")
                }
                default {
                    $runs.Add("OTHER:$($action.CimClass.CimClassName)")
                }
            }
        }

        ####
        #### <b style="color: #369FFF;">Returns</b>
        ####
        #### - `[PSCustomObject]`
        ####     - `[string]`: __TaskName__ / __TaskPath__ / __State__ / __Author__
        ####         - *Identity and current state.*
        ####     - `[string]`: __RunAs__
        ####         - *The principal, resolved from `UserId` or `GroupId`.*
        ####     - `[string]`: __PrincipalKind__
        ####         - *`User` or `Group`, naming which one produced `RunAs`.*
        ####     - `[string]`: __LogonType__ / __RunLevel__
        ####         - *How it logs on, and whether it runs at `Highest`.*
        ####     - `[string]`: __ActionKind__
        ####         - *`Exec`, `ComHandler`, or a comma joined mix.*
        ####     - `[string]`: __Runs__
        ####         - *Command line per exec action, or `COM:<ClassId>`.*
        ####     - `[datetime]`: __LastRunTime__ / __NextRunTime__
        ####         - *From `Get-ScheduledTaskInfo`, not from the task itself.*
        ####     - `[int]`: __LastTaskResult__
        ####         - *Raw result code.*
        ####     - `[string]`: __LastResultHex__
        ####         - *The same code as `0xXXXXXXXX`, which is the readable form.*
        ####     - `[string]`: __LastResultKind__
        ####         - *`Success`, `Informational`, or `Failure`, by HRESULT severity bit.*
        [PSCustomObject]@{
            TaskName       = $task.TaskName
            TaskPath       = $task.TaskPath
            State          = [string]$task.State
            Author         = $task.Author
            RunAs          = $principal
            PrincipalKind  = if ($isGroupPrincipal) { 'Group' } else { 'User' }
            LogonType      = [string]$task.Principal.LogonType
            RunLevel       = [string]$task.Principal.RunLevel
            ActionKind     = (@($task.Actions | ForEach-Object { $_.CimClass.CimClassName -replace '^MSFT_Task|Action$' }) -join ',')
            Runs           = ($runs -join ' | ')
            LastRunTime    = $info.LastRunTime
            LastTaskResult = $info.LastTaskResult
            LastResultHex  = '0x{0:X8}' -f $resultCode
            LastResultKind = $resultKind
            NextRunTime    = $info.NextRunTime
        }
    }
}
####
#### ---
####
