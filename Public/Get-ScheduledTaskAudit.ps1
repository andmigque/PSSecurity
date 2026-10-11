if ($IsWindows) {
    Set-StrictMode -Version Latest


    function Get-ScheduledTaskAudit {
        <#
    .SYNOPSIS
        Gets scheduled task configuration and last-run details.

    .DESCRIPTION
        Returns one report describing task states, last results, identities,
        privilege levels, actions, and reported next-run times. Results retains
        individual records; Errors contains audit retrieval failures only.
        NeverRun is identified by 0x00041303, not by an old timestamp.
        A missing next-run time does not prove a task has no trigger.
        NonZeroExitCode requires application-specific interpretation.
        ReviewTasks selects enabled tasks with failures, nonzero exit codes,
        termination, or unavailable run information; it is not a risk verdict.
        State, outcome, identity, and scheduling counts overlap.
        Missing fields are Unknown; absent next-run times are Not reported.
        AuditError is None on successful retrieval. Report fields never contain null.

    .OUTPUTS
        One PSCustomObject with task counts, ByState, ByLastResult, ByRunAs,
        ByRunLevel, ByActionKind, ReviewTasks, Results, and Errors.
        TotalTasks counts discovered tasks. AuditErrorTasks counts retrieval
        failures, independently of last-run outcomes. Empty input returns
        zero counts and empty arrays. Enumeration errors terminate the audit.

    .PARAMETER TaskPath
        Scheduled task path filter. Defaults to \*.

    .EXAMPLE
        $report = Get-ScheduledTaskAudit -TaskPath '\*'
        $report
        $report.ReviewTasks | Format-Table TaskName, LastResultKind, LastResultHex

        Returns a task summary with individual records in Results. Elevation is needed for complete enumeration.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            [Parameter(HelpMessage = 'Scheduled task path filter. Defaults to \*.')][string]$TaskPath = '\*'
        )

        if (-not (Test-Administrator)) {
            Write-Warning 'Get-ScheduledTaskAudit is not elevated. Enumeration is incomplete and omits SYSTEM context tasks.'
        }

        $tasks = @(Get-ScheduledTask -TaskPath $TaskPath -ErrorAction Stop)
        $results = [System.Collections.Generic.List[object]]::new()
        $errors = [System.Collections.Generic.List[object]]::new()
        foreach ($task in $tasks) {

            $info = $null
            $auditError = 'None'
            try {
                $info = $task | Get-ScheduledTaskInfo -ErrorAction Stop
                if ($null -eq $info) { throw 'No task run information returned.' }
            }
            catch {
                $auditError = $_.Exception.Message
                $errors.Add([pscustomobject]@{
                        Path    = "$($task.TaskPath)$($task.TaskName)"
                        Message = $auditError
                    })
            }

            $isGroupPrincipal = [string]::IsNullOrWhiteSpace($task.Principal.UserId)
            $principal = if ($isGroupPrincipal) { $task.Principal.GroupId } else { $task.Principal.UserId }

            $resultCode = $null
            $resultKind = 'Unknown'
            if ($null -ne $info -and $null -ne $info.LastTaskResult) {
                $resultCode = [uint32]($info.LastTaskResult -band 0xFFFFFFFFL)
                $resultKind = switch ($resultCode) {
                    0 { 'Success'; break }
                    0x00041300 { 'Ready'; break }
                    0x00041301 { 'Running'; break }
                    0x00041302 { 'Disabled'; break }
                    0x00041303 { 'NeverRun'; break }
                    0x00041304 { 'NoMoreRuns'; break }
                    0x00041305 { 'NotScheduled'; break }
                    0x00041306 { 'Terminated'; break }
                    0x00041307 { 'NoValidTriggers'; break }
                    0x00041308 { 'EventTrigger'; break }
                    0x0004131B { 'SomeTriggersFailed'; break }
                    0x0004131C { 'BatchLogonProblem'; break }
                    0x00041325 { 'Queued'; break }
                    default {
                        if ($resultCode -band 0x80000000L) { 'Failure' }
                        else { 'NonZeroExitCode' }
                    }
                }
            }

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

            $record = [PSCustomObject]@{
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
                LastRunTime    = if ($null -ne $info) { $info.LastRunTime } else { 'Unknown' }
                LastTaskResult = if ($null -ne $info) { $info.LastTaskResult } else { 'Unknown' }
                LastResultHex  = if ($null -ne $resultCode) { '0x{0:X8}' -f $resultCode } else { 'Unknown' }
                LastResultKind = $resultKind
                NextRunTime    = if ($null -ne $info) { $info.NextRunTime } else { 'Unknown' }
                AuditError     = $auditError
            }
            if ([string]::IsNullOrWhiteSpace([string]$record.NextRunTime) -or $record.NextRunTime -eq 'Unknown') {
                $record.NextRunTime = 'Not reported'
            }
            foreach ($property in $record.PSObject.Properties) {
                if ([string]::IsNullOrWhiteSpace([string]$property.Value)) { $property.Value = 'Unknown' }
            }
            $results.Add($record)
        }

        $rows = $results.ToArray()
        $enabled = @($rows | Where-Object { $_.State -in 'Ready', 'Running', 'Queued' })
        $reviewKinds = @('Failure', 'NonZeroExitCode', 'Terminated', 'Unknown',
            'NoValidTriggers', 'NotScheduled', 'SomeTriggersFailed', 'BatchLogonProblem')
        # Breakdowns count tasks, not action instances; mixed action kinds stay combined.
        $breakdowns = @{}
        foreach ($property in 'State', 'LastResultKind', 'RunAs', 'RunLevel', 'ActionKind') {
            $breakdowns[$property] = @($rows | Group-Object -Property $property |
                    Sort-Object Count -Descending | ForEach-Object {
                        [pscustomobject]@{ Name = $_.Name; Count = $_.Count }
                    })
        }
        [pscustomobject]@{
            TotalTasks              = $tasks.Count
            EnabledTasks            = $enabled.Count
            DisabledTasks           = @($rows | Where-Object { $_.State -eq 'Disabled' }).Count
            RunningTasks            = @($rows | Where-Object { $_.State -eq 'Running' }).Count
            NeverRunTasks           = @($rows | Where-Object { $_.LastResultKind -eq 'NeverRun' }).Count
            LastRunSuccessTasks     = @($rows | Where-Object { $_.LastResultKind -eq 'Success' }).Count
            LastRunFailureTasks     = @($rows | Where-Object { $_.LastResultKind -eq 'Failure' }).Count
            NonZeroExitCodeTasks    = @($rows | Where-Object { $_.LastResultKind -eq 'NonZeroExitCode' }).Count
            HighestPrivilegeTasks   = @($rows | Where-Object { $_.RunLevel -eq 'Highest' }).Count
            SystemTasks             = @($rows | Where-Object { $_.RunAs -in 'SYSTEM', 'NT AUTHORITY\SYSTEM', 'S-1-5-18' }).Count
            GroupPrincipalTasks     = @($rows | Where-Object { $_.PrincipalKind -eq 'Group' }).Count
            WithNextRunTimeTasks    = @($rows | Where-Object { $_.NextRunTime -ne 'Not reported' }).Count
            WithoutNextRunTimeTasks = @($rows | Where-Object { $_.NextRunTime -eq 'Not reported' }).Count
            AuditErrorTasks         = $errors.Count
            ByState                 = $breakdowns['State']
            ByLastResult            = $breakdowns['LastResultKind']
            ByRunAs                 = $breakdowns['RunAs']
            ByRunLevel              = $breakdowns['RunLevel']
            ByActionKind            = $breakdowns['ActionKind']
            ReviewTasks             = @($enabled | Where-Object { $_.LastResultKind -in $reviewKinds -or $_.AuditError -ne 'None' })
            Results                 = $rows
            Errors                  = $errors.ToArray()
        }
    }
}