## Use Write-Host Carefully

> Use `Write-Host` only to write formatted text to the host console.

- It doesn't write objects to the **Success** pipeline.

> `[Console]::WriteLine()` can be an order of magnitude faster.

- This holds in `pwsh.exe`, `powershell.exe`, and `powershell_ise.exe`.
- It isn't guaranteed to work in all hosts.
- Its output isn't captured by `Start-Transcript`.

---

## JIT Compilation

> PowerShell compiles script code to interpreted bytecode.

- Since PowerShell 3, repeated loops can be JIT-compiled to native code.

> Loops with fewer than 300 instructions are eligible.

- Larger loops are too costly to compile.
- After 16 iterations, the loop is compiled in the background.
- Once compiled, execution moves to the native code.

---

## Avoid Repeated Function Calls

> Calling a function can be expensive.

- In a long-running tight loop, move the loop inside the function.

Consider the following examples:

```powershell
$tests = @{
    'Simple for-loop'       = {
        param([int] $RepeatCount, [random] $RanGen)

        for ($i = 0; $i -lt $RepeatCount; $i++) {
            $null = $RanGen.Next()
        }
    }
    'Wrapped in a function' = {
        param([int] $RepeatCount, [random] $RanGen)

        function Get-RandomNumberCore {
            param ($Rng)

            $Rng.Next()
        }

        for ($i = 0; $i -lt $RepeatCount; $i++) {
            $null = Get-RandomNumberCore -Rng $RanGen
        }
    }
    'for-loop in a function' = {
        param([int] $RepeatCount, [random] $RanGen)

        function Get-RandomNumberAll {
            param ($Rng, $Count)

            for ($i = 0; $i -lt $Count; $i++) {
                $null = $Rng.Next()
            }
        }

        Get-RandomNumberAll -Rng $RanGen -Count $RepeatCount
    }
}

5kb, 10kb, 100kb | ForEach-Object {
    $Rng = [random]::new()
    $groupResult = foreach ($test in $tests.GetEnumerator()) {
        $ms = Measure-Command { & $test.Value -RepeatCount $_ -RanGen $Rng }

        [pscustomobject]@{
            CollectionSize    = $_
            Test              = $test.Key
            TotalMilliseconds = [Math]::Round($ms.TotalMilliseconds,2)
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

> The **Simple for-loop** is the performance baseline.

- The second test wraps the random number call in a function.
- That function is called inside a tight loop.
- The third test moves the loop inside the function.
- It calls the function once and generates the same count of numbers.

```Output
CollectionSize Test                   TotalMilliseconds RelativeSpeed
-------------- ----                   ----------------- -------------
          5120 for-loop in a function              9.62 1x
          5120 Simple for-loop                    10.55 1.1x
          5120 Wrapped in a function              62.39 6.49x
         10240 Simple for-loop                    17.79 1x
         10240 for-loop in a function             18.48 1.04x
         10240 Wrapped in a function             127.39 7.16x
        102400 for-loop in a function            179.19 1x
        102400 Simple for-loop                   181.58 1.01x
        102400 Wrapped in a function            1155.57 6.45x
```

---

## Avoid Wrapping Cmdlet Pipelines

> Most cmdlets are implemented for the pipeline.

- The pipeline is a sequential syntax and process.

```powershell
cmdlet1 | cmdlet2 | cmdlet3
```

> Initializing a new pipeline can be expensive.

- Avoid wrapping a cmdlet pipeline inside another pipeline.

> In this example, `Input.csv` contains 2100 lines.

- `Export-Csv` is wrapped inside the `ForEach-Object` pipeline.
- It runs once for every iteration.

```powershell
$measure = Measure-Command -Expression {
    Import-Csv .\Input.csv | ForEach-Object -Begin { $Id = 1 } -Process {
        [pscustomobject]@{
            Id   = $Id
            Name = $_.opened_by
        } | Export-Csv .\Output1.csv -Append
    }
}

'Wrapped = {0:N2} ms' -f $measure.TotalMilliseconds
```

```Output
Wrapped = 15,968.78 ms
```

> Next, `Export-Csv` moves outside the `ForEach-Object` pipeline.

- It runs only once.
- It still processes every object from `ForEach-Object`.

```powershell
$measure = Measure-Command -Expression {
    Import-Csv .\Input.csv | ForEach-Object -Begin { $Id = 2 } -Process {
        [pscustomobject]@{
            Id   = $Id
            Name = $_.opened_by
        }
    } | Export-Csv .\Output2.csv
}

'Unwrapped = {0:N2} ms' -f $measure.TotalMilliseconds
```

```Output
Unwrapped = 42.92 ms
```

> The unwrapped example is **372 times faster**.

- The wrapped version also needs the **Append** parameter.
- The unwrapped version doesn't.
