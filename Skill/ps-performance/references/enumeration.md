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

[about-arrays-where]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_arrays#where
[about-booleans]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_booleans
[about-comparison]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators
