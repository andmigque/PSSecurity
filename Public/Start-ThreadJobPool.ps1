#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Start-ThreadJobPool {
    <#
    .SYNOPSIS
        Starts the thread job scheduler and returns the started pool.

    .DESCRIPTION
        Runs the scheduler asynchronously in the pool's runspace. Summary
        returns counts by job state. Status returns the jobs in each state.
        Both expose Active (Running), Completed, Failed, and Stopped. Reading
        either property takes a fresh snapshot, including after dispatch ends.

    .PARAMETER Pool
        The pool returned by Initialize-Pool.

    .PARAMETER ThreadCount
        Accepts 0 through 255. Omit ThreadCount or pass 0 to use the default
        from Get-DefaultThreadCount. The scheduler uses the smallest of the
        resolved request, the default, and the initial job count.

    .INPUTS
        PSCustomObject.

    .OUTPUTS
        The supplied pool with Scheduler, AsyncResult, Summary, and Status
        properties.

    .NOTES
        $global:PSSecurityThreadPool references the started pool.
        AsyncResult tracks the scheduler invocation. Its completion means the
        scheduler has finished dispatching jobs. Wait-Job on the ThreadJob
        array waits for the jobs themselves.

    .EXAMPLE
        $pool = Initialize-ThreadJobBag -ThreadJob $threadJobs |
            Initialize-Pool |
            Start-ThreadJobPool -ThreadCount 8

        Starts the pool with up to eight concurrent jobs and returns immediately.

    .EXAMPLE
        $pool.Summary
        $pool.Status.Active

        Shows the current counts and the running ThreadJob objects.

    .EXAMPLE
        $pool.ThreadJob | Wait-Job | Receive-Job

        Waits for the supplied jobs and reads their output.
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

    try {
        ($schedulerRunspace = [PowerShell]::Create()).Runspace = $Pool.Runspace
        [ScriptBlock]$scheduler = Get-ThreadJobScheduler
        [void]$schedulerRunspace.AddScript($scheduler.ToString())
        [void]$schedulerRunspace.AddArgument($Pool.ConcurrentBag)
        [void]$schedulerRunspace.AddArgument($Pool.ThreadJob)
        [void]$schedulerRunspace.AddArgument($ThreadCount)
        $asyncResult = $schedulerRunspace.BeginInvoke()
    }
    catch {
        if (Get-Variable -Name schedulerRunspace -Scope Local -ErrorAction Ignore) {
            $schedulerRunspace.Dispose()
        }
        throw
    }

    $Pool | Add-Member -NotePropertyMembers @{
        Scheduler   = $schedulerRunspace
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
