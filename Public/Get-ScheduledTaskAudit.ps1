#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Get-ScheduledTaskAudit {
        <#
        .SYNOPSIS
            Gets scheduled task configuration and last-run details.

        .DESCRIPTION
            Returns one report describing task states, last results, identities,
            privilege levels, actions, and reported next-run times. Results contains the
            individual records; Errors contains audit retrieval failures only.

            NeverRun is identified by 0x00041303, not by an old timestamp. A missing
            next-run time does not prove a task has no trigger. NonZeroExitCode requires
            application-specific interpretation. ReviewTasks selects enabled tasks with
            failures, nonzero exit codes, termination, or unavailable run information;
            it is not a risk verdict. State, outcome, identity, and scheduling counts
            overlap.

            Missing fields are Unknown; absent next-run times are Not reported.
            AuditError is None on successful retrieval.

            Runs without elevation, with a warning: tasks that run as SYSTEM are omitted.
            Windows only.

        .PARAMETER TaskPath
            The scheduled task path filter. Wildcards are accepted. Defaults to \*.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One report with task counts,
            ByState, ByLastResult, ByRunAs, ByRunLevel, ByActionKind, ReviewTasks,
            Results, and Errors. TotalTasks counts discovered tasks. AuditErrorTasks
            counts retrieval failures, independently of last-run outcomes. A filter that
            matches no tasks returns zero counts and empty arrays. Enumeration errors
            stop the audit.

        .EXAMPLE
            $report = Get-ScheduledTaskAudit
            $report.ReviewTasks | Format-Table TaskName, LastResultKind, LastResultHex

            Audits every task and lists the enabled tasks that need review.

        .EXAMPLE
            (Get-ScheduledTaskAudit -TaskPath '\Microsoft\Windows\Defrag\').Results

            Returns the records for the tasks in one folder.

        .EXAMPLE
            (Get-ScheduledTaskAudit).ByRunAs

            Counts tasks by the identity they run as.
        #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(HelpMessage = 'Scheduled task path filter. Defaults to \*.')]
            [ValidateNotNullOrEmpty()]
            [string]$TaskPath = '\*'
        )

        if (-not (Test-Administrator)) {
            Write-Warning 'Get-ScheduledTaskAudit is not elevated. Enumeration is incomplete and omits SYSTEM context tasks.'
        }

        $tasks = @(Get-ScheduledTask -TaskPath $TaskPath -ErrorAction Stop)
        $results = [System.Collections.Generic.List[PSCustomObject]]::new()
        $errors = [System.Collections.Generic.List[PSCustomObject]]::new()

        foreach ($task in $tasks) {
            $auditError = 'None'
            # A failed lookup outputs nothing, so $info is empty and $hasInfo is false.
            $info = try {
                $task | Get-ScheduledTaskInfo -ErrorAction Stop
            }
            catch {
                $auditError = $_.Exception.Message
                $errors.Add([PSCustomObject]@{
                        Path    = "$($task.TaskPath)$($task.TaskName)"
                        Message = $auditError
                    })
            }
            $hasInfo = [bool]$info
            if (-not $hasInfo -and $auditError -eq 'None') {
                $auditError = 'No task run information returned.'
                $errors.Add([PSCustomObject]@{
                        Path    = "$($task.TaskPath)$($task.TaskName)"
                        Message = $auditError
                    })
            }

            $isGroupPrincipal = [string]::IsNullOrWhiteSpace($task.Principal.UserId)
            $principal = if ($isGroupPrincipal) {
                $task.Principal.GroupId
            }
            else {
                $task.Principal.UserId
            }

            # LastTaskResult can be 0, so test its type rather than its truth.
            $hasResult = $hasInfo -and $info.LastTaskResult -is [System.ValueType]
            $resultKind = 'Unknown'
            $resultHex = 'Unknown'
            if ($hasResult) {
                $resultCode = [uint32]($info.LastTaskResult -band 0xFFFFFFFFL)
                $resultHex = '0x{0:X8}' -f $resultCode
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
                        if ($resultCode -band 0x80000000L) {
                            'Failure'
                        }
                        else {
                            'NonZeroExitCode'
                        }
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
                LastRunTime    = if ($hasInfo) { $info.LastRunTime } else { 'Unknown' }
                LastTaskResult = if ($hasInfo) { $info.LastTaskResult } else { 'Unknown' }
                LastResultHex  = $resultHex
                LastResultKind = $resultKind
                NextRunTime    = if ($hasInfo) { $info.NextRunTime } else { 'Unknown' }
                AuditError     = $auditError
            }
            if ([string]::IsNullOrWhiteSpace([string]$record.NextRunTime) -or $record.NextRunTime -eq 'Unknown') {
                $record.NextRunTime = 'Not reported'
            }
            foreach ($property in $record.PSObject.Properties) {
                if ([string]::IsNullOrWhiteSpace([string]$property.Value)) {
                    $property.Value = 'Unknown'
                }
            }
            $results.Add($record)
        }

        $rows = $results.ToArray()
        $enabled = @($rows | Where-Object -Property State -In 'Ready', 'Running', 'Queued')
        $reviewKinds = @(
            'Failure', 'NonZeroExitCode', 'Terminated', 'Unknown',
            'NoValidTriggers', 'NotScheduled', 'SomeTriggersFailed', 'BatchLogonProblem'
        )

        # Breakdowns count tasks, not action instances; mixed action kinds stay combined.
        $breakdowns = @{}
        foreach ($property in 'State', 'LastResultKind', 'RunAs', 'RunLevel', 'ActionKind') {
            $breakdowns[$property] = @(
                $rows | Group-Object -Property $property | Sort-Object -Property Count -Descending | ForEach-Object {
                    [PSCustomObject]@{ Name = $_.Name; Count = $_.Count }
                }
            )
        }

        [PSCustomObject]@{
            TotalTasks              = $tasks.Count
            EnabledTasks            = $enabled.Count
            DisabledTasks           = @($rows | Where-Object -Property State -EQ 'Disabled').Count
            RunningTasks            = @($rows | Where-Object -Property State -EQ 'Running').Count
            NeverRunTasks           = @($rows | Where-Object -Property LastResultKind -EQ 'NeverRun').Count
            LastRunSuccessTasks     = @($rows | Where-Object -Property LastResultKind -EQ 'Success').Count
            LastRunFailureTasks     = @($rows | Where-Object -Property LastResultKind -EQ 'Failure').Count
            NonZeroExitCodeTasks    = @($rows | Where-Object -Property LastResultKind -EQ 'NonZeroExitCode').Count
            HighestPrivilegeTasks   = @($rows | Where-Object -Property RunLevel -EQ 'Highest').Count
            SystemTasks             = @($rows | Where-Object -Property RunAs -In 'SYSTEM', 'NT AUTHORITY\SYSTEM', 'S-1-5-18').Count
            GroupPrincipalTasks     = @($rows | Where-Object -Property PrincipalKind -EQ 'Group').Count
            WithNextRunTimeTasks    = @($rows | Where-Object -Property NextRunTime -NE 'Not reported').Count
            WithoutNextRunTimeTasks = @($rows | Where-Object -Property NextRunTime -EQ 'Not reported').Count
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
