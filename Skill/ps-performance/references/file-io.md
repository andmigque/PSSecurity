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
