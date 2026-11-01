# Get-ScheduledTaskAudit

*Gets scheduled task configuration and last-run details.*

## DESCRIPTION

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

## PARAMETERS

### -TaskPath

The scheduled task path filter. Wildcards are accepted. Defaults to \*.

## EXAMPLES

### Example 1

```powershell
$report = Get-ScheduledTaskAudit
$report.ReviewTasks | Format-Table TaskName, LastResultKind, LastResultHex
```

Audits every task and lists the enabled tasks that need review.

### Example 2

```powershell
(Get-ScheduledTaskAudit -TaskPath '\Microsoft\Windows\Defrag\').Results
```

Returns the records for the tasks in one folder.

### Example 3

```powershell
(Get-ScheduledTaskAudit).ByRunAs
```

Counts tasks by the identity they run as.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One report with task counts,
ByState, ByLastResult, ByRunAs, ByRunLevel, ByActionKind, ReviewTasks,
Results, and Errors. TotalTasks counts discovered tasks. AuditErrorTasks
counts retrieval failures, independently of last-run outcomes. A filter that
matches no tasks returns zero counts and empty arrays. Enumeration errors
stop the audit.

