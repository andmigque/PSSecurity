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

[hashtable]: https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-hashtable
