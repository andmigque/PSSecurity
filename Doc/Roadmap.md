# Roadmap

This document uses RFC normative language as written in the JSON RPC Spec https://www.jsonrpc.org/specification.
It uses requirements tables with rules that start with a Powershell approved verb. 

## 1. Planning

### 1.1 Get-Log

This function should operate on Windows Event Logs and Linux journal logs. 
It should provide a unified input and output api over the underlying log providers.

> This function **MUST** solve the *Powershell function Google Search* problem:

To execute this function, you need 1 function lookup and 3 google searches:

```powershell
 Get-WinEventData -LogName 'Microsoft-Windows-Windows Defender/Operational' -Id 1123 | Group-Object ProcessName
```

Solving this issue is the primary requirement.

## 2. Analysis

### 2.1 Get-Log Requirements

| # | Level | Rule |
| ---- | --- | --- |
| 2.1 | MUST | Resolve the *Powershell function Google Search* problem as outlined in 1.1 |
| 2.2 | MUST |  Register 2 Get-Log functions, Win and Lin, wrapped in standard platform if checks |
| 2.3 | MUST | Build a method for dynamically providing a validate set for log name. | 
| 2.4 | MUST NOT | Use Invoke-Expression |
| 2.5 | MUST | Read only and not mutate any system state |
| 2.6 | MUST NOT | Block authorized reads | 


### 2.2 Examples

#### 2.2.1

> This example uses Dynamic Validate Sets resolves the need for example described by requirement 2.3:

```powershell
class SubmoduleSetGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return @('Value', 'MoreValue','MostValue')
    }
}

class LifecycleSetGenerator : IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return @('Install', 'Build', 'Test', 'Lint', 'Doc', 'All')
    }
}

function Invoke-Memory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet([SubmoduleSetGenerator])]
        [string]$Name,
        [Parameter(Mandatory, Position = 1)]
        [ValidateSet([LifecycleSetGenerator])]
        [string]$Lifecycle
    )

    Enter-Submodule -Name $Name
    try {
        if ($Name -eq 'MostValue') {
            if ($Lifecycle -eq 'Install') {
                npm install
            }
            else {
                npm run $Lifecycle.ToLowerInvariant()
            }
        }
        else {
            if ($Lifecycle -eq 'All') {
                Invoke-Build
            }
            else {
                Invoke-Build -Task $Lifecycle
            }
        }
    }
    finally {
        Exit-Submodule
    }
}

```

#### Open Questions: 

- What about syslog? 
- For a later version, should we build log providers?