# Get Up to Speed

Use this sequence to understand the repository without crawling every file.

## 1. Load Order

Use the following load order to effectively start a new session in this project.

### 1.1 

Read [README.md](./README.md) for the module's purpose, requirements, and entry points.

### 1.2 

If the `ps-security` skill did not lead you here, read [SKILL.md](./Skill/ps-security/SKILL.md) from Usage onward.

### 1.3 

Read [PSSecurity.md](./Doc/PSSecurity.md) to understand how the module loads.

### 1.4 

Read [os.build.md](./Doc/os.build.md) to understand how the repository is built and verified.

If the `ps-security` skill led you here, do not read it again.

## 2. Stop and Route the Task

Do not read every function, test, or generated document. Use `HashIndex.json` to locate only the files needed for the current task.

### 2.1 Task to Doc Mapping Table

Generated files under `Doc` are read-first documentation. Change the Sharpdown comments in source, then regenerate the documentation.

#### Figure 2.1.1

| Task | Read next |
| --- | --- |
| Use or explain a function | Its file under `Doc/Public`. |
| Change a public function | Its `Doc/Public`, `Public`, and `Test` files. |
| Change a private helper | Its `Doc/Private`, `Private`, and related `Test` files. |
| Change module loading | `PSSecurity.psm1` after reading `Doc/PSSecurity.md`. |
| Change build behavior | `os.build.ps1` after reading `Doc/os.build.md`. |

## 3. 🪫👌Powershell Rules

Follow these rules when writing Powershell in this project:

### 3.1 Write Functions

✅ DO: Write `function`s in the `Public` directory when give arbitary 'write powershell' commands.
✅ DO: Use the function template to start off with: [PSFunction.ps1](./Template/PSFunction.ps1)

### 3.2 DO NOT Use Null. Null is NOT Allowed

❌ DO NOT use `$null`. Ever. For any reason EXCEPT for testing against

```powershell
if($null -eq $CustomObject) {
    Write-Error 'An unexpected error occurred'
    throw
}
```

### 3.3 Write-Error, then throw

Use `Write-Error`, followed by a `throw`

```powershell
if($null -eq $CustomObject) {
    Write-Error 'An unexpected error occurred'
    throw
}
```

### 3.4 Preferences

❌ DO NOT: Set ANY Preference in a function

```powershell
$ErrorActionPreference = 'Stop'
# ...more...code...
```

✅ DO: Use Paraemeter Preference Setting

```powershell
Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue
```

### 3.5 DO NOT Embed Data in a Function. Use a json config file.

❌ DO NOT:

```powershell
function Remove-UnwantedApps {
    $appTargets = @(
        [PSCustomObject]@{
            DisplayName  = 'Sound Recorder'
            PackageNames = @('Microsoft.WindowsSoundRecorder')
        }
        [PSCustomObject]@{
            DisplayName  = 'Start Experiences App'
            PackageNames = @('Microsoft.StartExperiencesApp')
        }
        [PSCustomObject]@{
            DisplayName  = 'Solitaire'
            PackageNames = @('Microsoft.MicrosoftSolitaireCollection')
        }
        [PSCustomObject]@{
            DisplayName  = 'Weather'
            PackageNames = @('Microsoft.BingWeather')
        }
    )
}
```

✅ DO: 

```json
[
  {
    "DisplayName": "Sound Recorder",
    "PackageNames": [
      "Microsoft.WindowsSoundRecorder"
    ]
  },
  {
    "DisplayName": "Start Experiences App",
    "PackageNames": [
      "Microsoft.StartExperiencesApp"
    ]
  },
  {
    "DisplayName": "Solitaire",
    "PackageNames": [
      "Microsoft.MicrosoftSolitaireCollection"
    ]
  },
  {
    "DisplayName": "Weather",
    "PackageNames": [
      "Microsoft.BingWeather"
    ]
  }
]
```

### 3.6 Write and Name functions Generically

❌ DO NOT:

```powershell
function Remove-UnwantedWindowsApps
```

✅ DO: 

```powershell
function Remove-App
```

### 3.7 Use singular Noun Naming

❌ DO NOT:

```powershell
function Remove-UnwantedWindowsApps
```

✅ DO: 

```powershell
function Remove-App
```

### 3.8 Suppressing Output

❌ DO NOT:

```powershell
    foreach ($i in 0..$args[0]) {
        $arraylist.Add($i) | Out-Null
    }
```

✅ DO: Cast to `[void]`

```powershell
    foreach ($i in 0..$args[0]) {
        [void] $arraylist.Add($i)
    }
```

```Output
Iterations Test              TotalMilliseconds RelativeSpeed
---------- ----              ----------------- -------------
     10240 Cast to [void]                62.96 1.71x
     51200 Cast to [void]               200.77 1.04x
     51200 Pipe to Out-Null             329.62 1.7x
    102400 Cast to [void]               405.24 1.05x
    102400 Pipe to Out-Null             572.94 1.48x
```

### 3.9 Avoid Array Addition

Generating a list of items is often done using an array with the addition operator:

❌ DO NOT:

```powershell
$results = @()
$results += Get-Something
$results += Get-SomethingElse
$results
```

✅ DO:

```powershell
$results = [System.Collections.Generic.List[Object]]::new()
$results.AddRange((Get-Something))
$results.AddRange((Get-SomethingElse))
$results
```

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

✅ DO: Use `[Object]` only when the collection intentionally contains different types.

```powershell
$objectList = [System.Collections.Generic.List[Object]]::new()
$objectList.Add(1)
$objectList.Add('2')
$objectList.Add(3.0)
$objectList | ForEach-Object { "$_ is $($_.GetType())" }
```

### 3.10 Use Type-Safe Collections

✅ DO: Use a type-specific collection when every item has the same type.

```powershell
$ListInt = [System.Collections.Generic.List[int]]::new()
for ($i = 0; $i -lt 1mb; $i++) {
    $ListInt.Add($i)
}
```

### 3.11 Avoid String Addition

❌ DO NOT: Build large strings repeatedly with the `+=` operator.

✅ DO: Use `-join` for large strings.

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

```

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

### 3.12 Process Large Files with .NET APIs

❌ DO NOT: Use a cmdlet pipeline to process a large file line by line.

```powershell
Get-Content $path | Where-Object Length -GT 10
```

This can be an order of magnitude slower than using .NET APIs directly. For example, you can use the .NET `[StreamReader]` class:

✅ DO:

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

You could also use the `ReadLines` method of `[System.IO.File]`, which wraps `StreamReader`, simplifies the reading process:

✅ DO:

```powershell
foreach ($line in [System.IO.File]::ReadLines($path)) {
    if ($line.Length -gt 10) {
        $line
    }
}
```

### 3.13 Use Hash Tables for Large Collection Lookups

Given two collections, one with an **Id** and **Name**, the other with **Name** and **Email**:

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

❌ DO NOT: Repeatedly filter one large collection for every item in another collection.

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

✅ DO: Build a hash table once and use keyed lookups.

```powershell
$LookupHash = @{}
foreach ($Account in $Accounts) {
    $LookupHash[$Account.Name] = $Account
}
```

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

This is much faster. While the looping filter took minutes to complete, the hash lookup takes less than a second.

### 3.14 Use Write-Host Carefully

❌ DO NOT: Use `Write-Host`. 

✅ DO: Use `Write-Output`.

### 3.15 Keep Loops Eligible for JIT Compilation

❌ DO NOT: Put more than 300 instructions in a performance-sensitive loop.

✅ DO: Keep tight loops small enough to be eligible for JIT compilation.

### 3.16 Avoid Repeated Function Calls

Calling a function can be an expensive operation.

❌ DO NOT: Call a wrapper function once for every iteration of a tight loop.

✅ DO: Move the loop inside the function and call the function once.

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

            [void]($Rng.Next())
        }

        for ($i = 0; $i -lt $RepeatCount; $i++) {
            [void](Get-RandomNumberCore -Rng $RanGen)
        }
    }
    'for-loop in a function' = {
        param([int] $RepeatCount, [random] $RanGen)

        function Get-RandomNumberAll {
            param ($Rng, $Count)

            for ($i = 0; $i -lt $Count; $i++) {
                [void]($Rng.Next())
            }
        }

        Get-RandomNumberAll -Rng $RanGen -Count $RepeatCount
    }
}

```

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

### 3.17 Avoid Wrapping Cmdlet Pipelines

Most cmdlets are implemented for the pipeline, which is a sequential syntax and process. For example:

```powershell
cmdlet1 | cmdlet2 | cmdlet3
```

❌ DO NOT:

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

✅ DO:

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

### 3.18 Avoid Unnecessary Collection Enumeration

❌ DO NOT: Use a full collection comparison when the condition only needs the first match.

```powershell
if ($Collection -like '*1*') { 'Found' }
```

✅ DO: Stop enumeration after the first match.

```powershell
$Collection = foreach ($x in 1..1MB) { $x }
(Measure-Command { if ($Collection -like '*1*') { 'Found' } }).TotalMilliseconds
633.3695
(Measure-Command { if ($Collection.Where({ $_ -like '*1*' }, 'first')) { 'Found' } }).TotalMilliseconds
2.607
```

### 3.19 Use Efficient Object Creation

❌ DO NOT: Use `New-Object` to create objects.

✅ DO: Use the `[pscustomobject]` type accelerator.

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

```output
Test           TotalSeconds
----           ------------
PSCustomObject         0.48
New-Object             3.37
```

✅ DO: Use the static `new()` method.

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

### 3.20 Use OrderedDictionary to Dynamically Create Objects

Assume you have the following API response stored in the variable `$json`.

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

❌ DO NOT: Add properties one at a time with `Add-Member` when creating many dynamic objects.

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

✅ DO: Build an ordered dictionary and cast it to `[pscustomobject]`.


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
```

$properties = 'Prop1', 'Prop2', 'Prop3', 'Prop4', 'Prop5'

```Output
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