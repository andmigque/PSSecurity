## Step 1: Suppressing Output

- [ ] Ensure casting to void instead of Out-Null

> There are many ways to avoid writing objects to the pipeline.

- Cast to `[void]`.
- Pipe to `Out-Null`.
- Assign or redirect to `$null`.

> Prefer `[void]`, even where `$null =` benchmarks faster.

- Assigning or redirecting to `$null` breaks the Never Null rule.
- At scale, the gap between `[void]` and `$null` is within a few percent.

Below is a benchmark of each technique:

```powershell
$tests = @{
    'Assign to $null' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            $null = $arraylist.Add($i)
        }
    }
    'Cast to [void]' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            [void] $arraylist.Add($i)
        }
    }
    'Redirect to $null' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            $arraylist.Add($i) > $null
        }
    }
    'Pipe to Out-Null' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            $arraylist.Add($i) | Out-Null
        }
    }
}

10kb, 50kb, 100kb | ForEach-Object {
    $groupResult = foreach ($test in $tests.GetEnumerator()) {
        $ms = (Measure-Command { & $test.Value $_ }).TotalMilliseconds

        [pscustomobject]@{
            Iterations        = $_
            Test              = $test.Key
            TotalMilliseconds = [Math]::Round($ms, 2)
        }

        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }

    $groupResult = $groupResult | Sort-Object TotalMilliseconds
    $groupResult | Select-Object *, @{
        Name       = 'RelativeSpeed'
        Expression = {
            $relativeSpeed = $_.TotalMilliseconds / $groupResult[0].TotalMilliseconds
            [Math]::Round($relativeSpeed, 2).ToString() + 'x'
        }
    }
}
```

> These tests ran on Windows 11 in PowerShell 7.3.4.

```Output
Iterations Test              TotalMilliseconds RelativeSpeed
---------- ----              ----------------- -------------
     10240 Assign to $null               36.74 1x
     10240 Redirect to $null             55.84 1.52x
     10240 Cast to [void]                62.96 1.71x
     10240 Pipe to Out-Null              81.65 2.22x
     51200 Assign to $null              193.92 1x
     51200 Cast to [void]               200.77 1.04x
     51200 Redirect to $null            219.69 1.13x
     51200 Pipe to Out-Null             329.62 1.7x
    102400 Redirect to $null            386.08 1x
    102400 Assign to $null              392.13 1.02x
    102400 Cast to [void]               405.24 1.05x
    102400 Pipe to Out-Null             572.94 1.48x
```

- Results vary with hardware, PowerShell version, and system load.
