# Get-ApplicationSignatureAudit

*Audits Authenticode signatures of discoverable applications.*

## DESCRIPTION

Finds every application on the PATH with Get-Command, then checks each
signature with Get-AuthenticodeSignature on a pool of thread jobs, using
Enter-ThreadQueue. Applications in WindowsApps are excluded. Each application
produces a signature record, or an Error record when the check throws.

Returns one summary with counts by outcome, every record in Results, and the
inconclusive checks in Errors. Result order is not guaranteed. Windows only.

## PARAMETERS

### -ThrottleLimit

The maximum number of applications checked at once, from 1 through 255.
Defaults to 75% of the processors, rounded down, and at least 1.

## EXAMPLES

### Example 1

```powershell
$result = Get-ApplicationSignatureAudit
$result.Results | Where-Object -Property Status -NE 'Valid' | Format-Table Name, Status, Path
```

Lists the applications without a valid signature.

### Example 2

```powershell
Get-ApplicationSignatureAudit -ThrottleLimit 8
```

Checks up to eight applications at once.

### Example 3

```powershell
(Get-ApplicationSignatureAudit).Errors
```

Lists the applications whose signature could not be checked.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One summary with these
properties:

- TotalApplications: applications found.
- AuditedApplications: checks with a conclusive status.
- ValidApplications: status Valid.
- UnsignedApplications: status NotSigned.
- InvalidApplications: status HashMismatch or NotTrusted.
- FailedApplications: inconclusive statuses and checks that threw.
- Results: one record per application.
- Errors: Path and Message of each failed check. Unsigned and invalid
applications are not errors.

No applications returns zero counts and empty arrays.

