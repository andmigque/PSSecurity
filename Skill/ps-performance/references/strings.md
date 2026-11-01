## Step 4: String Addition

- [ ] Ensure usage of the `-join` operator for string addition

> Strings are immutable.

- Each addition creates a new string large enough for both operands.
- The contents of both operands are copied into the new string.
- For small strings, this overhead may not matter.
- For large strings, it affects performance and memory consumption.

> There are at least two alternatives.

- The [`-join` operator][about-join] concatenates strings.
- The .NET `[StringBuilder]` class provides a mutable string.

The following benchmark compares all three techniques:

```powershell
$tests = @{
    'StringBuilder' = {
        $sb = [System.Text.StringBuilder]::new()
        foreach ($i in 0..$args[0]) {
            $sb = $sb.AppendLine("Iteration $i")
        }
        $sb.ToString()
    }
    'Join operator' = {
        $string = @(
            foreach ($i in 0..$args[0]) {
                "Iteration $i"
            }
        ) -join "`n"
        $string
    }
    'Addition Assignment +=' = {
        $string = ''
        foreach ($i in 0..$args[0]) {
            $string += "Iteration $i`n"
        }
        $string
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

> These tests ran on Windows 11 in PowerShell 7.4.2.

- The `-join` operator is the fastest.
- The `[StringBuilder]` class is second.

```Output
Iterations Test                   TotalMilliseconds RelativeSpeed
---------- ----                   ----------------- -------------
     10240 Join operator                      14.75 1x
     10240 StringBuilder                      62.44 4.23x
     10240 Addition Assignment +=            619.64 42.01x
     51200 Join operator                      43.15 1x
     51200 StringBuilder                     304.32 7.05x
     51200 Addition Assignment +=          14225.13 329.67x
    102400 Join operator                      85.62 1x
    102400 StringBuilder                     499.12 5.83x
    102400 Addition Assignment +=          67640.79 790.01x
```

- Results vary with hardware, PowerShell version, and system load.

[about-join]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_join
