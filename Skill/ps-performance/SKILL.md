---
name: ps-performance
description: Use this skill when you need to refactor PowerShell code to be highly performant.
---

# ps-performance

> Use this skill when you need to refactor PowerShell code to be highly performant.

## Idiomatic vs Fast

> Direct .NET calls tend to beat idiomatic PowerShell.

- Idiomatic PowerShell uses cmdlets, functions, and the pipeline.
- It resorts to .NET only when necessary.
- Scripts that call .NET directly and avoid the pipeline run faster.

> [!NOTE]
> Many of these techniques aren't idiomatic and can hurt readability.
> Use idiomatic PowerShell unless performance dictates otherwise.

---

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

---

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

---

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

---

## Processing Large Files

> The idiomatic way to filter a file uses the pipeline.

```powershell
Get-Content $path | Where-Object Length -GT 10
```

> .NET APIs can be an order of magnitude faster.

- The `[StreamReader]` class reads the file line by line.

```powershell
try {
    $reader = [System.IO.StreamReader]::new($path)
    while (-not $reader.EndOfStream) {
        $line = $reader.ReadLine()
        if ($line.Length -gt 10) {
            $line
        }
    }
}
finally {
    if ($reader) {
        $reader.Dispose()
    }
}
```

> `[System.IO.File]::ReadLines()` wraps `StreamReader`.

- It simplifies the reading process.

```powershell
foreach ($line in [System.IO.File]::ReadLines($path)) {
    if ($line.Length -gt 10) {
        $line
    }
}
```

---

## Hash Table Lookups

> Records in different collections often share a property.

- For example, a name links an ID in one list to an email in another.
- Iterating the first list to filter the second is slow.
- The repeated filtering has a large overhead.

> The first collection has an **Id** and **Name**.

- The second has a **Name** and **Email**.

```powershell
$Employees = 1..10000 | ForEach-Object {
    [pscustomobject]@{
        Id   = $_
        Name = "Name$_"
    }
}

$Accounts = 2500..7500 | ForEach-Object {
    [pscustomobject]@{
        Name  = "Name$_"
        Email = "Name$_@fabrikam.com"
    }
}
```

> The usual reconciliation filters the second collection per record.

```powershell
$Results = $Employees | ForEach-Object -Process {
    $Employee = $_

    $Account = $Accounts | Where-Object -FilterScript {
        $_.Name -eq $Employee.Name
    }

    [pscustomobject]@{
        Id    = $Employee.Id
        Name  = $Employee.Name
        Email = $Account.Email
    }
}
```

- This filters all 5000 `$Accounts` items for every employee.
- It can take minutes, even for a single-value lookup.

> Instead, build a [hash table][hashtable] keyed on the shared **Name**.

- Each value is the matching account.

```powershell
$LookupHash = @{}
foreach ($Account in $Accounts) {
    $LookupHash[$Account.Name] = $Account
}
```

> Key lookups are much faster than filtering by property value.

- PowerShell checks whether the key exists and uses its value.
- It doesn't check every item in the collection.

```powershell
$Results = $Employees | ForEach-Object -Process {
    $Email = $LookupHash[$_.Name].Email
    [pscustomobject]@{
        Id    = $_.Id
        Name  = $_.Name
        Email = $Email
    }
}
```

- The looping filter takes minutes.
- The hash lookup takes less than a second.

---

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

---

## Avoid Unnecessary Enumeration

> [Comparison operators][about-comparison] can filter collections.

- When the left-hand value is a collection, the operator returns matches.
- This is a simple way to filter a collection.

```powershell
PS> $Collection = 1..99
PS> ($Collection -like '*1*') -join ' '

1 10 11 12 13 14 15 16 17 18 19 21 31 41 51 61 71 81 91
```

> In a conditional, this feature can perform poorly.

- The condition only needs a [boolean][about-booleans] result.

```powershell
if ($Collection -like '*1*') { 'Found' }
```

- PowerShell compares the right-hand value to every element.
- It returns a collection of results.
- A non-empty result evaluates as `$true`.
- The condition is true at the first match.
- PowerShell still enumerates the entire collection.
- For large collections, this has a significant performance impact.

> The [`Where()`][about-arrays-where] method stops at the first match.

```powershell
# Create an array of 1048576 items
$Collection = foreach ($x in 1..1MB) { $x }
(Measure-Command { if ($Collection -like '*1*') { 'Found' } }).TotalMilliseconds
633.3695
(Measure-Command { if ($Collection.Where({ $_ -like '*1*' }, 'first')) { 'Found' } }).TotalMilliseconds
2.607
```

- For a million items, `Where()` is significantly faster.

---

## Object Creation

> The `New-Object` cmdlet can be slow.

- This benchmark compares it to the `[pscustomobject]` type accelerator.

```powershell
Measure-Command {
    $test = 'PSCustomObject'
    for ($i = 0; $i -lt 100000; $i++) {
        $resultObject = [pscustomobject]@{
            Name = 'Name'
            Path = 'FullName'
        }
    }
} | Select-Object @{n='Test';e={$test}},TotalSeconds

Measure-Command {
    $test = 'New-Object'
    for ($i = 0; $i -lt 100000; $i++) {
        $resultObject = New-Object -TypeName psobject -Property @{
            Name = 'Name'
            Path = 'FullName'
        }
    }
} | Select-Object @{n='Test';e={$test}},TotalSeconds
```

```Output
Test           TotalSeconds
----           ------------
PSCustomObject         0.48
New-Object             3.37
```

> PowerShell 5.0 added a static `new()` method to all .NET types.

- This benchmark compares `New-Object` to `new()`.

```powershell
Measure-Command {
    $test = 'new() method'
    for ($i = 0; $i -lt 100000; $i++) {
        $sb = [System.Text.StringBuilder]::new(1000)
    }
} | Select-Object @{n='Test';e={$test}},TotalSeconds

Measure-Command {
    $test = 'New-Object'
    for ($i = 0; $i -lt 100000; $i++) {
        $sb = New-Object -TypeName System.Text.StringBuilder -ArgumentList 1000
    }
} | Select-Object @{n='Test';e={$test}},TotalSeconds
```

```Output
Test         TotalSeconds
----         ------------
new() method         0.59
New-Object           3.17
```

---

## Dynamic Object Creation

> Build dynamic objects from an `[OrderedDictionary]`.

- A common approach creates a **PSObject** and calls `Add-Member`.
- For small collections, the cost may be negligible.
- For large collections, it becomes very noticeable.
- Instead, fill an `[OrderedDictionary]` and cast it to `[pscustomobject]`.
- See *Creating ordered dictionaries* in [about_Hash_Tables][about-ordered].

> Assume this API response is stored in `$json`.

```json
{
  "tables": [
    {
      "name": "PrimaryResult",
      "columns": [
        { "name": "Type", "type": "string" },
        { "name": "TenantId", "type": "string" },
        { "name": "count_", "type": "long" }
      ],
      "rows": [
        [ "Usage", "63613592-b6f7-4c3d-a390-22ba13102111", "1" ],
        [ "Usage", "d436f322-a9f4-4aad-9a7d-271fbf66001c", "1" ],
        [ "BillingFact", "63613592-b6f7-4c3d-a390-22ba13102111", "1" ],
        [ "BillingFact", "d436f322-a9f4-4aad-9a7d-271fbf66001c", "1" ],
        [ "Operation", "63613592-b6f7-4c3d-a390-22ba13102111", "7" ],
        [ "Operation", "d436f322-a9f4-4aad-9a7d-271fbf66001c", "5" ]
      ]
    }
  ]
}
```

> To export this data to CSV, first create objects with `Add-Member`.

```powershell
$data = $json | ConvertFrom-Json
$columns = $data.tables.columns
$result = foreach ($row in $data.tables.rows) {
    $obj = [psobject]::new()
    $index = 0

    foreach ($column in $columns) {
        $obj | Add-Member -MemberType NoteProperty -Name $column.name -Value $row[$index++]
    }

    $obj
}
```

> With an `OrderedDictionary`, the code becomes the following.

```powershell
$data = $json | ConvertFrom-Json
$columns = $data.tables.columns
$result = foreach ($row in $data.tables.rows) {
    $obj = [ordered]@{}
    $index = 0

    foreach ($column in $columns) {
        $obj[$column.name] = $row[$index++]
    }

    [pscustomobject] $obj
}
```

> Both approaches produce the same `$result`.

```output
Type        TenantId                             count_
----        --------                             ------
Usage       63613592-b6f7-4c3d-a390-22ba13102111 1
Usage       d436f322-a9f4-4aad-9a7d-271fbf66001c 1
BillingFact 63613592-b6f7-4c3d-a390-22ba13102111 1
BillingFact d436f322-a9f4-4aad-9a7d-271fbf66001c 1
Operation   63613592-b6f7-4c3d-a390-22ba13102111 7
Operation   d436f322-a9f4-4aad-9a7d-271fbf66001c 5
```

- The dictionary approach scales better as objects and properties grow.

> This benchmark compares three techniques with 5 properties.

```powershell
$tests = @{
    '[ordered] into [pscustomobject] cast' = {
        param([int] $Iterations, [string[]] $Props)

        foreach ($i in 1..$Iterations) {
            $obj = [ordered]@{}
            foreach ($prop in $Props) {
                $obj[$prop] = $i
            }
            [pscustomobject] $obj
        }
    }
    'Add-Member'                           = {
        param([int] $Iterations, [string[]] $Props)

        foreach ($i in 1..$Iterations) {
            $obj = [psobject]::new()
            foreach ($prop in $Props) {
                $obj | Add-Member -MemberType NoteProperty -Name $prop -Value $i
            }
            $obj
        }
    }
    'PSObject.Properties.Add'              = {
        param([int] $Iterations, [string[]] $Props)

        # this is how, behind the scenes, `Add-Member` attaches
        # new properties to our PSObject.
        # Worth having it here for performance comparison

        foreach ($i in 1..$Iterations) {
            $obj = [psobject]::new()
            foreach ($prop in $Props) {
                $obj.psobject.Properties.Add(
                    [psnoteproperty]::new($prop, $i))
            }
            $obj
        }
    }
}

$properties = 'Prop1', 'Prop2', 'Prop3', 'Prop4', 'Prop5'

1kb, 10kb, 100kb | ForEach-Object {
    $groupResult = foreach ($test in $tests.GetEnumerator()) {
        $ms = Measure-Command { & $test.Value -Iterations $_ -Props $properties }

        [pscustomobject]@{
            Iterations        = $_
            Test              = $test.Key
            TotalMilliseconds = [Math]::Round($ms.TotalMilliseconds, 2)
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

> These are the results.

```output
Iterations Test                                 TotalMilliseconds RelativeSpeed
---------- ----                                 ----------------- -------------
      1024 [ordered] into [pscustomobject] cast             22.00 1x
      1024 PSObject.Properties.Add                         153.17 6.96x
      1024 Add-Member                                      261.96 11.91x
     10240 [ordered] into [pscustomobject] cast             65.24 1x
     10240 PSObject.Properties.Add                        1293.07 19.82x
     10240 Add-Member                                     2203.03 33.77x
    102400 [ordered] into [pscustomobject] cast            639.83 1x
    102400 PSObject.Properties.Add                       13914.67 21.75x
    102400 Add-Member                                    23496.08 36.72x
```

---

## Related Links

- [`$null`][about-null]
- [System.Void][void]
- [Out-Null][out-null]
- [List&lt;T&gt;][list]
- [Add(T) method][list-add]
- [System.String][string]
- [System.Int32][int32]
- [System.Object][object]
- [ToArray() method][list-toarray]
- [System.Collections.ArrayList][arraylist]
- [System.Text.StringBuilder][stringbuilder]
- [System.IO.StreamReader][streamreader]
- [File::ReadLines() method][readlines]
- [Write-Host][write-host]
- [Add-Member][add-member]

[whats-new-75]: https://learn.microsoft.com/powershell/scripting/whats-new/what-s-new-in-powershell-75#engine-improvements
[about-join]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_join
[hashtable]: https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-hashtable
[about-comparison]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators
[about-booleans]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_booleans
[about-arrays-where]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_arrays#where
[about-ordered]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_hash_tables#creating-ordered-dictionaries
[about-null]: https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-null
[void]: https://learn.microsoft.com/dotnet/api/system.void
[out-null]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/out-null
[list]: https://learn.microsoft.com/dotnet/api/system.collections.generic.list-1
[list-add]: https://learn.microsoft.com/dotnet/api/system.collections.generic.list-1.add
[string]: https://learn.microsoft.com/dotnet/api/system.string
[int32]: https://learn.microsoft.com/dotnet/api/system.int32
[object]: https://learn.microsoft.com/dotnet/api/system.object
[list-toarray]: https://learn.microsoft.com/dotnet/api/system.collections.generic.list-1.toarray
[arraylist]: https://learn.microsoft.com/dotnet/api/system.collections.arraylist
[stringbuilder]: https://learn.microsoft.com/dotnet/api/system.text.stringbuilder
[streamreader]: https://learn.microsoft.com/dotnet/api/system.io.streamreader
[readlines]: https://learn.microsoft.com/dotnet/api/system.io.file.readlines
[write-host]: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/write-host
[add-member]: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/add-member
