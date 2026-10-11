if ($IsWindows) {
    Set-StrictMode -Version Latest

    function Get-ApplicationSignatureAudit {
        <#
    .SYNOPSIS
        Audits Authenticode signatures of discoverable applications.

    .DESCRIPTION
        Uses a shared queue and up to Throttle reusable thread jobs. Each
        application produces the existing signature record or an error-status record.
        Result order is not guaranteed. WindowsApps entries are excluded.
        Progress shows discovery, completed attempts, and each worker's current
        application. The caller refreshes progress every 200 milliseconds while
        workers are active. Signature checks are indeterminate: Authenticode does
        not expose byte-level progress. Progress respects ProgressPreference and
        does not add records to the success stream.

    .NOTES
        Supports Windows PowerShell 5.1 and PowerShell 7 on Windows. Requires
        Start-ThreadJob. If unavailable, imports ThreadJob, installing it for the
        current user from PSGallery when necessary, like Compress-FileTree.
        Dependency installation requires network access and may install NuGet.
        Invocation-owned jobs are stopped and removed on completion or interruption.
        Progress entries are cleared even if discovery or dependency setup fails.
        Cancellation is checked between applications; a synchronous signature
        check must return before cooperative cancellation can take effect.

    .PARAMETER Throttle
        Maximum concurrent workers, from 1 through 255. Defaults to 4.

    .INPUTS
        None. This function does not accept pipeline input.

    .OUTPUTS
        System.Management.Automation.PSCustomObject
        TotalApplications, AuditedApplications, ValidApplications,
        UnsignedApplications, InvalidApplications, FailedApplications, Results, and Errors.
        Results contains the original audit records. Errors contains Path and Message.
        AuditedApplications counts completed checks with a conclusive status.
        ValidApplications counts Valid; UnsignedApplications counts NotSigned.
        InvalidApplications counts HashMismatch and NotTrusted.
        FailedApplications counts inconclusive verification statuses and exceptions.
        Errors contains only those verification failures, not unsigned or invalid files.
        An empty discovery returns zero counts and empty arrays.

    .EXAMPLE
        $result = Get-ApplicationSignatureAudit -Throttle 8
        $result.Results

        Returns a summary and inspects the individual audit records.

    .EXAMPLE
        & {
            $ProgressPreference = 'SilentlyContinue'
            Get-ApplicationSignatureAudit
        }

        Suppresses progress in a child scope while retaining the summary object.
    #>
        [CmdletBinding()]
        [OutputType([pscustomobject])]
        param(
            # Maximum concurrent workers, from 1 through 255. Defaults to 4.
            [Parameter(Mandatory = $false, HelpMessage = 'Enter the maximum number of workers (1-255).')]
            [ValidateRange(1, 255)]
            [int]$Throttle = 4
        )

        $applications = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()

        # Reuse a bounded set of workers; each claims the next application from the queue.
        $auditApplication = {
            param($applications, $cancellation, $processed, $failed, $applicationProgress, $workerId, $outcomes)

            $cmd = $null
            $processed[$workerId] = 0
            $failed[$workerId] = 0

            while (-not $cancellation.IsCancellationRequested -and $applications.TryDequeue([ref]$cmd)) {
                $outcome = 'Failed'
                try {
                    $applicationProgress[$workerId] = $cmd.Source
                    $sig = Get-AuthenticodeSignature -FilePath $cmd.Source -ErrorAction Stop
                    # Classify the status, not the absence of a signer certificate.
                    $outcome = switch ($sig.Status.ToString()) {
                        'Valid' { 'Valid' }
                        'NotSigned' { 'Unsigned' }
                        'HashMismatch' { 'Invalid' }
                        'NotTrusted' { 'Invalid' }
                        default { 'Failed' }
                    }

                    [PSCustomObject]@{
                        Name              = $cmd.Name
                        Path              = $cmd.Source
                        Status            = $sig.Status.ToString()
                        StatusMessage     = $sig.StatusMessage
                        SignerCertificate = if ($sig.SignerCertificate) { $sig.SignerCertificate.Subject } else { 'Unsigned' }
                        TimeStamper       = if ($sig.TimeStamperCertificate) { $sig.TimeStamperCertificate.Subject } else { 'None' }
                        IsOSBinary        = $sig.IsOSBinary
                        SignatureType     = $sig.SignatureType.ToString()
                    }
                }
                catch {
                    $outcome = 'Failed'
                    [PSCustomObject]@{
                        Name              = $cmd.Name
                        Path              = $cmd.Source
                        Status            = 'Error'
                        StatusMessage     = $_.Exception.Message
                        SignerCertificate = 'Error'
                        TimeStamper       = 'None'
                        IsOSBinary        = $false
                        SignatureType     = 'Unknown'
                    }
                }
                finally {
                    [void]$outcomes.AddOrUpdate($outcome, 1, [System.Func[string, int, int]] { param($key, $value) $value + 1 })
                    if ($outcome -eq 'Failed') { $failed[$workerId]++ }
                    $processed[$workerId]++
                    $removedProgress = $null
                    [void]$applicationProgress.TryRemove($workerId, [ref]$removedProgress)
                }
            }
        }

        $totalApplications = 0
        $processed = [System.Collections.Concurrent.ConcurrentDictionary[int, int]]::new()
        $failed = [System.Collections.Concurrent.ConcurrentDictionary[int, int]]::new()
        $outcomes = [System.Collections.Concurrent.ConcurrentDictionary[string, int]]::new()
        foreach ($outcome in 'Valid', 'Unsigned', 'Invalid', 'Failed') { $outcomes[$outcome] = 0 }
        $applicationProgress = [System.Collections.Concurrent.ConcurrentDictionary[int, string]]::new()
        $results = @()
        $workerCount = 0
        $jobs = [System.Collections.Generic.List[System.Management.Automation.Job]]::new()
        $cancellation = [System.Threading.CancellationTokenSource]::new()
        try {
            Write-Progress -Id 0 -Activity 'Auditing application signatures' -Status 'Discovering applications' -PercentComplete -1
            $progressTimer = [System.Diagnostics.Stopwatch]::StartNew()
            # Stream discovery so the caller can refresh progress before it finishes.
            Get-Command -CommandType Application -All | ForEach-Object {
                if ($_.Source -notlike '*\AppData\Local\Microsoft\WindowsApps\*') {
                    $applications.Enqueue($_)
                }
                if ($progressTimer.ElapsedMilliseconds -ge 200) {
                    Write-Progress -Id 0 -Activity 'Auditing application signatures' `
                        -Status "$($applications.Count) applications discovered" -PercentComplete -1
                    $progressTimer.Restart()
                }
            }

            # Freeze the denominator before workers begin consuming the shared queue.
            $totalApplications = $applications.Count
            $workerCount = [Math]::Min($Throttle, $totalApplications)
            Write-Progress -Id 0 -Activity 'Auditing application signatures' `
                -Status "$totalApplications applications discovered; preparing workers" -PercentComplete -1

            if (-not $applications.IsEmpty -and -not (Get-Command Start-ThreadJob -ErrorAction SilentlyContinue)) {
                # Reuse the built-in command on PowerShell 7. Bootstrap the Gallery module
                # only when the command is unavailable, as on Windows PowerShell 5.1.
                if (-not (Get-Module -Name ThreadJob -ListAvailable)) {
                    # Older PowerShellGet versions otherwise prompt to bootstrap NuGet.
                    $nuget = Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue |
                    Where-Object { $_.Version -ge [version]'2.8.5.201' }
                    if (-not $nuget) {
                        [void](Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' `
                                -Scope CurrentUser -Force -Confirm:$false -ErrorAction Stop)
                    }
                    [void](Import-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -ErrorAction Stop)
                    Install-Module -Name ThreadJob -Repository PSGallery -Scope CurrentUser `
                        -AllowClobber -Force -Confirm:$false -ErrorAction Stop
                }
                Import-Module -Name ThreadJob -ErrorAction Stop
                [void](Get-Command Start-ThreadJob -ErrorAction Stop)
            }

            for ($workerId = 0; $workerId -lt $workerCount; $workerId++) {
                $jobParameters = @{
                    ScriptBlock   = $auditApplication
                    ArgumentList  = @($applications, $cancellation, $processed, $failed, $applicationProgress, $workerId, $outcomes)
                    ThrottleLimit = $Throttle
                    ErrorAction   = 'Stop'
                }
                $jobs.Add((Start-ThreadJob @jobParameters))
            }
            if ($jobs.Count -gt 0) {
                do {
                    $finished = 0
                    foreach ($count in $processed.Values) { $finished += $count }
                    $failedCount = 0
                    foreach ($count in $failed.Values) { $failedCount += $count }
                    $active = $false
                    foreach ($job in $jobs) {
                        if ($job.State -notin 'Completed', 'Failed', 'Stopped') { $active = $true; break }
                    }
                    $percentComplete = [int][Math]::Floor(100 * $finished / $totalApplications)
                    $status = '{0} of {1} processed; {2} valid; {3} unsigned; {4} invalid; {5} errors' -f $finished, $totalApplications, $outcomes['Valid'], $outcomes['Unsigned'], $outcomes['Invalid'], $failedCount
                    Write-Progress -Id 0 -Activity 'Auditing application signatures' -Status $status -PercentComplete $percentComplete

                    for ($workerId = 0; $workerId -lt $workerCount; $workerId++) {
                        $applicationPath = $null
                        if ($applicationProgress.TryGetValue($workerId, [ref]$applicationPath)) {
                            $progressParameters = @{
                                Id              = $workerId + 1
                                ParentId        = 0
                                Activity        = $applicationPath
                                Status          = 'Checking signature'
                                PercentComplete = -1
                            }
                            Write-Progress @progressParameters
                        }
                        else {
                            Write-Progress -Id ($workerId + 1) -Activity 'Checking signature' -Completed
                        }
                    }
                    if ($active) { Start-Sleep -Milliseconds 200 }
                } while ($active)

                $results = @($jobs | Receive-Job -Wait -ErrorAction Stop)
            }
        }
        finally {
            # Stop only this invocation's jobs, including when startup or receiving fails.
            $cancellation.Cancel()
            for ($workerId = 0; $workerId -lt $jobs.Count; $workerId++) {
                Write-Progress -Id ($workerId + 1) -Activity 'Checking signature' -Completed
            }
            Write-Progress -Id 0 -Activity 'Auditing application signatures' -Completed
            if ($jobs.Count -gt 0) {
                $jobs | Stop-Job
                $jobs | Remove-Job
            }
            $cancellation.Dispose()
        }
        $failedApplications = 0
        foreach ($count in $failed.Values) { $failedApplications += $count }
        [pscustomobject]@{
            TotalApplications    = $totalApplications
            AuditedApplications  = $totalApplications - $failedApplications
            ValidApplications    = $outcomes['Valid']
            UnsignedApplications = $outcomes['Unsigned']
            InvalidApplications  = $outcomes['Invalid']
            FailedApplications   = $failedApplications
            Results              = $results
            Errors               = @(foreach ($result in $results) {
                    if ($result.Status -notin 'Valid', 'NotSigned', 'HashMismatch', 'NotTrusted') {
                        [pscustomobject]@{ Path = $result.Path; Message = $result.StatusMessage }
                    }
                })
        }
    }

}