#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Start-ThreadJobPool {
    <#
    .SYNOPSIS
        Starts the thread job scheduler and returns the started pool.

    .DESCRIPTION
        Runs the scheduler asynchronously in the pool's runspace. Summary
        returns counts by job state. Status returns the jobs in each state.
        Active corresponds to the Running state.

    .PARAMETER Pool
        The pool returned by Initialize-Pool.

    .PARAMETER ThreadCount
        The requested number of concurrent jobs. Zero selects the default
        from Get-DefaultThreadCount. The default and the initial bag count
        both cap the effective thread count.

    .INPUTS
        PSCustomObject.

    .OUTPUTS
        The supplied pool with Scheduler, AsyncResult, Summary, and Status
        properties.

    .NOTES
        $global:PSSecurityThreadPool references the started pool.

    .EXAMPLE
        $pool = Initialize-ThreadJobBag -ThreadJob $threadJobs |
            Initialize-Pool |
            Start-ThreadJobPool -ThreadCount 8

        $pool.Summary
        $pool.Status.Active
        $pool.Status.Failed
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Enter the pool returned by Initialize-Pool.')]
        [PSCustomObject]$Pool,

        [ValidateRange(0, 255)]
        [int]$ThreadCount = 0
    )

    $default = (Get-DefaultThreadCount).ThreadCount
    $requested = $ThreadCount -eq 0 ? $default : $ThreadCount
    $ThreadCount = [Math]::Min($Pool.ConcurrentBag.Count, [Math]::Min($requested, $default))

    $schedule = {
        param($Bag, [ThreadJob.ThreadJob[]]$ThreadJob, [int]$ThreadCount)

        do {
            $activeThreadJobCount = $ThreadJob.Where({ $_.State -eq 'Running' }).Count

            for ($i = $activeThreadJobCount; $i -lt $ThreadCount; $i++) {
                if ($Bag.Count -gt 0) {
                    $Bag.Take().StartJob()
                }
            }
        } while ($Bag.Count -gt 0)
    }

    $scheduler = [PowerShell]::Create()
    try {
        $scheduler.Runspace = $Pool.Runspace
        [void]$scheduler.AddScript($schedule.ToString())
        [void]$scheduler.AddArgument($Pool.ConcurrentBag)
        [void]$scheduler.AddArgument($Pool.ThreadJob)
        [void]$scheduler.AddArgument($ThreadCount)
        $asyncResult = $scheduler.BeginInvoke()
    }
    catch {
        $scheduler.Dispose()
        throw
    }

    $Pool | Add-Member -NotePropertyMembers @{
        Scheduler   = $scheduler
        AsyncResult = $asyncResult
    } -ErrorAction Stop

    $Pool | Add-Member -MemberType ScriptProperty -Name Summary -Value {
        $states = @(
            foreach ($job in $this.ThreadJob) {
                $job.State
            }
        )

        [PSCustomObject]@{
            Active    = ($states -eq 'Running').Count
            Completed = ($states -eq 'Completed').Count
            Failed    = ($states -eq 'Failed').Count
            Stopped   = ($states -eq 'Stopped').Count
        }
    } -ErrorAction Stop

    $Pool | Add-Member -MemberType ScriptProperty -Name Status -Value {
        $active    = [System.Collections.Generic.List[ThreadJob.ThreadJob]]::new()
        $completed = [System.Collections.Generic.List[ThreadJob.ThreadJob]]::new()
        $failed    = [System.Collections.Generic.List[ThreadJob.ThreadJob]]::new()
        $stopped   = [System.Collections.Generic.List[ThreadJob.ThreadJob]]::new()

        foreach ($job in $this.ThreadJob) {
            switch ($job.State) {
                'Running'   { $active.Add($job) }
                'Completed' { $completed.Add($job) }
                'Failed'    { $failed.Add($job) }
                'Stopped'   { $stopped.Add($job) }
            }
        }

        [PSCustomObject]@{
            Active    = $active.ToArray()
            Completed = $completed.ToArray()
            Failed    = $failed.ToArray()
            Stopped   = $stopped.ToArray()
        }
    } -ErrorAction Stop

    $global:PSSecurityThreadPool = $Pool
    $Pool
}
