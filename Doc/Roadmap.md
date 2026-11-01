# Roadmap

This document uses RFC normative language as written in the [JSON-RPC 2.0 Specification][1].
It uses requirements tables with rules that start with a PowerShell approved verb.
*This* roadmap is for functions in `Public` and `Private`.

  [1]: https://www.jsonrpc.org/specification

### 🧭 Summary

- [Roadmap](#roadmap)
    - [🧭 Summary](#-summary)
  - [📋 1. Planning](#-1-planning)
    - [📜 1.1 Get-Log](#-11-get-log)
    - [🔎 1.2 Search-RedactionPatternInFile](#-12-search-redactionpatterninfile)
  - [🔬 2. Analysis](#-2-analysis)
    - [📜 2.1 Get-Log Requirements](#-21-get-log-requirements)
      - [🧪 2.1.7 Dynamic validate set example](#-217-dynamic-validate-set-example)
    - [🔎 2.2 Search-RedactionPatternInFile Requirements](#-22-search-redactionpatterninfile-requirements)
  - [❓ 3. Open Questions](#-3-open-questions)
    - [📜 3.1 Get-Log](#-31-get-log)

## 📋 1. Planning

### 📜 1.1 Get-Log

This function should operate on Windows Event Logs and Linux journal logs.
It should provide a unified input and output API over the underlying log providers.

> This function **MUST** solve the *PowerShell function Google Search* problem:

To execute this function, you need 1 function lookup and 3 Google searches:

```powershell
Get-WinEventData -LogName 'Microsoft-Windows-Windows Defender/Operational' -Id 1123 | Group-Object ProcessName
```

Solving this issue is the primary requirement.

> Back to the [summary](#-summary)

### 🔎 1.2 Search-RedactionPatternInFile

This function searches files for text patterns that should be redacted.
See the [cui-llm-redact][2] skill for more information.
See [sensitive-regexes][3].

Using both the CUI skill and the sensitive regexes as a primer, a model should be sent into deep research mode with the intent of generating an exhaustive list of sensitive regexes.

These regexes will then go into an `InformationTypes.psd1` file, matching the existing guidance in [cui-llm-redact][2].

This function then **MUST** combine [Search-PatternInFile][4] with the `InformationTypes.psd1` to create `Search-RedactionPatternInFile`.

Once this function is complete, we will expand the [cui-llm-redact][2] skill to incorporate this new tool.

  [2]: ../Skill/cui-llm-redact/SKILL.md
  [3]: https://raw.githubusercontent.com/Trendyol/awesome-regex-list/refs/heads/main/README.md
  [4]: ../Public/Search-PatternInFile.ps1

> Back to the [summary](#-summary)

## 🔬 2. Analysis

### 📜 2.1 Get-Log Requirements

| # | Level | Rule |
| ----- | --- | --- |
| 2.1.1 | MUST | Resolve the *PowerShell function Google Search* problem as outlined in [1.1](#-11-get-log) |
| 2.1.2 | MUST | Register 2 Get-Log functions, Win and Lin, wrapped in standard platform if checks |
| 2.1.3 | MUST | Build a method for dynamically providing a validate set for log name |
| 2.1.4 | MUST NOT | Use Invoke-Expression |
| 2.1.5 | MUST | Read only and not mutate any system state |
| 2.1.6 | MUST NOT | Block authorized reads |

#### 🧪 2.1.7 Dynamic validate set example

> This example uses dynamic validate sets to meet requirement 2.1.3:

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

> Back to the [summary](#-summary)

### 🔎 2.2 Search-RedactionPatternInFile Requirements

| # | Level | Rule |
| ----- | --- | --- |
| 2.2.1 | MUST | Use [Search-PatternInFile][4] to search files for patterns from `InformationTypes.psd1` |
| 2.2.2 | MUST | Name each match by its information type, as [cui-llm-redact][2] does |
| 2.2.3 | MUST NOT | Write to the searched files |
| 2.2.4 | MUST NOT | Hide findings |

> Back to the [summary](#-summary)

## ❓ 3. Open Questions

### 📜 3.1 Get-Log

- What about syslog?
- For a later version, should we build log providers?

> Back to the [summary](#-summary)
