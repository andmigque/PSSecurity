# No end of line comments

- Comments go above the code you wish to comment on
- This practice introduces end of line parsing errors
- Is one of the most common difficult to pin point bugs

_Example_

> Do not do this
```
enum Relation {
    Interprets       # Caelus → ToDo.txt
    Designs          # Caelus → Specification
    Applies          # Caelus → RxPwsh Paradigm
}
```
> Instead, do this
```
<#
    .SYNOPSIS
    The available relationships in this memory

    .PARAMETER Interprets
    .PARAMETER Designs  
    .PARAMETER Applies
#>
enum Relation {
    Interprets       # Caelus → ToDo.txt
    Designs          # Caelus → Specification
    Applies          # Caelus → RxPwsh Paradigm
}
```

### Wisdom
IDE's use comments in languages like Powershell and Python to 
provide code completion. You WILL introduce bugs with 
end of line comments