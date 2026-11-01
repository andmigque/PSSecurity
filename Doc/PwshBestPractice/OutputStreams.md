# Output Streams

PowerShell provides multiple output streams for different purposes. Using the correct stream ensures proper pipeline behavior, logging, and user experience.

## The Six PowerShell Streams

1. **Output** (Stream 1) - Success output, pipeline data
2. **Error** (Stream 2) - Non-terminating errors
3. **Warning** (Stream 3) - Warning messages
4. **Verbose** (Stream 4) - Detailed progress information
5. **Debug** (Stream 5) - Debugging information
6. **Information** (Stream 6) - Informational messages (PS 5.0+)

## Guidelines

- **Use implicit output for pipeline data** - Objects written to the pipeline without `Write-Output`
- **Use `Write-Verbose` for detailed progress** - Controlled by `-Verbose` parameter
- **Use `Write-Warning` for non-fatal issues** - User should be notified but operation continues
- **Use `Write-Error` for failures** - Non-terminating errors that don't stop execution
- **Use `Write-Debug` for debugging** - Controlled by `-Debug` parameter
- **AVOID `Write-Host`** - Breaks pipeline, cannot be redirected or captured

## Pattern: Implicit Output (Preferred)

```powershell
function Get-NetworkStats {
    [CmdletBinding()]
    param([string]$Interface = 'eth0')

    $stats = Get-NetworkData -Interface $Interface

    # Implicit output - automatically goes to pipeline
    [PSCustomObject]@{
        Interface     = $Interface
        BytesReceived = $stats.RxBytes
        BytesSent     = $stats.TxBytes
    }
}
```

## Pattern: Verbose Progress Tracking

```powershell
function Process-LargeDataset {
    [CmdletBinding()]
    param([string[]]$Files)

    Write-Verbose "Processing $($Files.Count) files"

    $results = foreach ($file in $Files) {
        Write-Verbose "Processing file: $file"

        $data = Get-Content -Path $file

        [PSCustomObject]@{
            File = $file
            Size = (Get-Item $file).Length
        }
    }

    Write-Verbose "Processing complete. Processed $($results.Count) files."

    # Return results implicitly
    $results
}
```

Usage:
```powershell
# Normal usage - no verbose output
Process-LargeDataset -Files $fileList

# With verbose output
Process-LargeDataset -Files $fileList -Verbose
```

## Pattern: Warnings for Non-Fatal Issues

```powershell
function Get-SystemMetrics {
    [CmdletBinding()]
    param()

    $metrics = @{}

    try {
        $metrics['CPU'] = Get-CpuPercent
    }
    catch {
        Write-Warning "Failed to retrieve CPU metrics: $_"
        $metrics['CPU'] = $null
    }

    try {
        $metrics['Memory'] = Get-MemoryPercent
    }
    catch {
        Write-Warning "Failed to retrieve memory metrics: $_"
        $metrics['Memory'] = $null
    }

    # Return partial results even if some metrics failed
    [PSCustomObject]$metrics
}
```

## Pattern: Debug Information

```powershell
function Invoke-ComplexOperation {
    [CmdletBinding()]
    param([string]$InputData)

    Write-Debug "Input data length: $($InputData.Length)"

    $parsed = Parse-Input -Data $InputData
    Write-Debug "Parsed data: $($parsed | ConvertTo-Json -Compress)"

    $result = Process-Data -Parsed $parsed
    Write-Debug "Result object type: $($result.GetType().FullName)"

    # Return result
    $result
}
```

Usage:
```powershell
# Enable debug output
$DebugPreference = 'Continue'
Invoke-ComplexOperation -InputData $data

# Or use -Debug parameter
Invoke-ComplexOperation -InputData $data -Debug
```

## Anti-Patterns to Avoid

### ❌ Using Write-Host for Output

```powershell
function Get-ServerStatus {
    $status = Test-Connection -ComputerName 'server01'

    # BAD: Cannot be captured or redirected!
    Write-Host "Server is online"
}
```

**Why it's bad:**
- Breaks the pipeline
- Cannot be captured: `$result = Get-ServerStatus` gets nothing
- Cannot be redirected: `Get-ServerStatus > output.txt` doesn't work
- Not suppressible

### ✅ Do This Instead

```powershell
function Get-ServerStatus {
    [CmdletBinding()]
    param()

    $isOnline = Test-Connection -ComputerName 'server01' -Quiet

    # Good: Returns an object
    [PSCustomObject]@{
        Server   = 'server01'
        Status   = if ($isOnline) { 'Online' } else { 'Offline' }
        Timestamp = Get-Date
    }
}
```

### ❌ Using Write-Output Unnecessarily

```powershell
function Get-Data {
    $result = Get-Something

    # Unnecessary - implicit output is preferred
    Write-Output $result
}
```

### ✅ Do This Instead

```powershell
function Get-Data {
    $result = Get-Something

    # Implicit output
    $result
}
```

### ❌ Mixing Output Types

```powershell
function Get-ComplexData {
    Write-Host "Starting operation..."  # Goes to host (bad)

    $data = Process-Data

    Write-Verbose "Processing complete"  # Goes to verbose stream (good)

    # Returns data
    $data
}
```

### ✅ Do This Instead

```powershell
function Get-ComplexData {
    [CmdletBinding()]
    param()

    Write-Verbose "Starting operation..."  # Proper verbose message

    $data = Process-Data

    Write-Verbose "Processing complete"

    # Returns data
    $data
}
```

## When to Use Each Stream

| Stream | Use Case | Example |
|--------|----------|---------|
| **Implicit Output** | Pipeline data, function results | `[PSCustomObject]@{ ... }` |
| **Write-Verbose** | Progress updates, detailed logging | `Write-Verbose "Processing file 10/100"` |
| **Write-Warning** | Non-fatal issues, deprecation notices | `Write-Warning "File not found, using defaults"` |
| **Write-Error** | Operation failures that continue | `Write-Error "Failed to connect to database"` |
| **Write-Debug** | Debugging information, variable dumps | `Write-Debug "Variable value: $var"` |
| **Write-Host** | **NEVER in PowerNixx** (interactive scripts only) | ❌ Don't use |

## Wisdom

- **Pipeline-first design** - Always return objects that can be piped to other commands
- **Verbose is for users** - Use `-Verbose` to show what your function is doing without cluttering normal output
- **Warnings don't stop execution** - Use them for issues that users should know about but that don't prevent completion
- **Debug is for developers** - Use `-Debug` for troubleshooting, not for end users

Proper stream usage makes PowerNixx functions composable, testable, and user-friendly.
