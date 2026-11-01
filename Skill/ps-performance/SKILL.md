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

## Techniques

> Read only the reference that matches the code in front of you.

- [Step 1: Suppressing Output](references/output-suppression.md)
    - [ ] Ensure casting to void instead of Out-Null
- [Step 2 and 3: Array Addition and Type-Safe Collections](references/collections.md)
    - [ ] Ensure += array addition is not used
    - [ ] Check the usage of type-safe collections
- [Step 4: String Addition](references/strings.md)
    - [ ] Ensure usage of the `-join` operator for string addition
- [Processing Large Files](references/file-io.md)
    - `StreamReader` and `File::ReadLines()` over `Get-Content`
- [Hash Table Lookups](references/lookups.md)
    - Key lookups over repeated `Where-Object` filtering
- [Write-Host, JIT, Function Calls, and Wrapped Pipelines](references/pipeline-and-calls.md)
    - Move tight loops inside functions
    - Never wrap a cmdlet pipeline inside another pipeline
- [Avoid Unnecessary Enumeration](references/enumeration.md)
    - `.Where({}, 'first')` in conditionals over comparison filtering
- [Object Creation and Dynamic Object Creation](references/object-creation.md)
    - `[pscustomobject]` and `::new()` over `New-Object`
    - `[ordered]` cast to `[pscustomobject]` over `Add-Member`

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
