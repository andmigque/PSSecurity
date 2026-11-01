## Step 2: Array Addition

- [ ] Ensure += array addition is not used

> Lists are often built with the array addition operator.

```powershell
$results = @()
$results += Get-Something
$results += Get-SomethingElse
$results
```

> [!NOTE]
> PowerShell 7.5 optimized array addition.
> It no longer creates a new array for each operation.
> This section still applies to versions prior to 7.5.
> See [What's New in PowerShell 7.5][whats-new-75].

> Array addition is inefficient because arrays have a fixed size.

- Each addition creates a new array large enough for both operands.
- The elements of both operands are copied into the new array.
- For small collections, this overhead may not matter.
- For large collections, performance suffers.

> If you don't require an array, use a typed generic list.

```powershell
$results = [System.Collections.Generic.List[Object]]::new()
$results.AddRange((Get-Something))
$results.AddRange((Get-SomethingElse))
$results
```

> The cost of `+=` grows with collection size and addition count.

- This benchmark compares three techniques.
- Explicit assignment to an array is the baseline.
- `Add(T)` on a `[List<T>]` is the second technique.
- Array addition with `+=` is the third.

```powershell
$tests = @{
    'PowerShell Explicit Assignment' = {
        param($Count)

        $result = foreach($i in 1..$Count) {
            $i
        }
    }
    '.Add(T) to List<T>' = {
        param($Count)

        $result = [Collections.Generic.List[int]]::new()
        foreach($i in 1..$Count) {
            $result.Add($i)
        }
    }
    '+= Operator to Array' = {
        param($Count)

        $result = @()
        foreach($i in 1..$Count) {
            $result += $i
        }
    }
}

5kb, 10kb, 100kb | ForEach-Object {
    $groupResult = foreach($test in $tests.GetEnumerator()) {
        $ms = (Measure-Command { & $test.Value -Count $_ }).TotalMilliseconds

        [pscustomobject]@{
            CollectionSize    = $_
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
CollectionSize Test                           TotalMilliseconds RelativeSpeed
-------------- ----                           ----------------- -------------
          5120 PowerShell Explicit Assignment             26.65 1x
          5120 .Add(T) to List<T>                        110.98 4.16x
          5120 += Operator to Array                      402.91 15.12x
         10240 PowerShell Explicit Assignment              0.49 1x
         10240 .Add(T) to List<T>                        137.67 280.96x
         10240 += Operator to Array                     1678.13 3424.76x
        102400 PowerShell Explicit Assignment             11.18 1x
        102400 .Add(T) to List<T>                       1384.03 123.8x
        102400 += Operator to Array                   201991.06 18067.18x
```

- For large collections, `+=` is dramatically slower than `List<T>`.

> A `[List<T>]` is created with a specific type, like `[string]` or `[int]`.

- Objects of a different type are cast to the list type.
- If the cast fails, the method throws an exception.

```powershell
$intList = [System.Collections.Generic.List[int]]::new()
$intList.Add(1)
$intList.Add('2')
$intList.Add(3.0)
$intList.Add('Four')
$intList
```

```Output
MethodException:
Line |
   5 |  $intList.Add('Four')
     |  ~~~~~~~~~~~~~~~~~~~~
     | Cannot convert argument "item", with value: "Four", for "Add" to type
     "System.Int32": "Cannot convert value "Four" to type "System.Int32".
     Error: "The input string 'Four' was not in a correct format.""

1
2
3
```

> For mixed types, create the list with `[Object]` as its type.

- You can enumerate the collection to inspect each object's type.

```powershell
$objectList = [System.Collections.Generic.List[Object]]::new()
$objectList.Add(1)
$objectList.Add('2')
$objectList.Add(3.0)
$objectList | ForEach-Object { "$_ is $($_.GetType())" }
```

```Output
1 is int
2 is string
3 is double
```

> If you do require an array, call `ToArray()` on the list.

- You can also let PowerShell create the array for you.

```powershell
$results = @(
    Get-Something
    Get-SomethingElse
)
```

- PowerShell holds the pipeline results in an `[ArrayList]`.
- Before assigning to `$results`, it converts the list to `[Object[]]`.

---

## Step 3: Type-Safe Collections

- [ ] Check the usage of type-safe collections

> PowerShell is loosely typed, which can cost performance.

- Type-safe collections consume less memory and run faster.
- Compare the following examples.

```powershell
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$ListInt = [System.Collections.Generic.List[int]]::new()
for ($i = 0; $i -lt 1mb; $i++) {
    $ListInt.Add($i)
}
$Stopwatch.Stop()
Write-Host "Time to add 1mb integers to List[int]: $($Stopwatch.Elapsed.TotalSeconds) seconds."
```

```Output
Time to add 1mb integers to List[int]: 9.8841501 seconds.
```

> A list of `[int]` is faster than a list of `[Object]`.

```powershell
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$ListObject = [System.Collections.Generic.List[Object]]::new()
for ($i = 0; $i -lt 1mb; $i++) {
    $ListObject.Add($i)
}
$Stopwatch.Stop()
Write-Host "Time to add 1mb integers to List[Object]: $($Stopwatch.Elapsed.TotalSeconds) seconds."
```

```Output
Time to add 1mb integers to List[Object]: 10.5677782 seconds.
```

[whats-new-75]: https://learn.microsoft.com/powershell/scripting/whats-new/what-s-new-in-powershell-75#engine-improvements
