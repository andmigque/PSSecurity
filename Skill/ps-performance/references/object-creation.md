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

[about-ordered]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_hash_tables#creating-ordered-dictionaries
