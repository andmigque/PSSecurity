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
    - [📜 1.3 FedRAMP Rules](#-13-fedramp-rules)
    - [📜 1.4 FedRAMP Marketplace](#-14-fedramp-marketplace)
  - [🔬 2. Analysis](#-2-analysis)
    - [📜 2.1 Get-Log Requirements](#-21-get-log-requirements)
      - [🧪 2.1.7 Dynamic validate set example](#-217-dynamic-validate-set-example)
    - [🔎 2.2 Search-RedactionPatternInFile Requirements](#-22-search-redactionpatterninfile-requirements)
    - [📜 2.3 FedRAMP Requirements](#-23-fedramp-requirements)
      - [🧪 2.3.6 FedRAMP rules example](#-236-fedramp-rules-example)
    - [📜 2.4 FedRAMP Marketplace Requirements](#-24-fedramp-marketplace-requirements)
      - [🧪 2.4.6 Marketplace category example](#-246-marketplace-category-example)
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
Use the `SensitivePattern` entries in [Config/Setting.psd1][2] and the
[sensitive regex examples][3] as starting points for researching additional patterns.

Store the resulting regular expressions by information type in `InformationTypes.psd1`.

This function then **MUST** combine [Search-PatternInFile][4] with the `InformationTypes.psd1` to create `Search-RedactionPatternInFile`.

Once this function is complete, document how to use it in a redaction workflow.

  [2]: ../Config/Setting.psd1
  [3]: https://raw.githubusercontent.com/Trendyol/awesome-regex-list/refs/heads/main/README.md
  [4]: ../Public/Search-PatternInFile.ps1

> Back to the [summary](#-summary)

### 📜 1.3 FedRAMP Rules

FedRAMP rules change over time. PSSecurity needs the exact wording from the current published release so engineers can implement controls against the requirements in effect.

> Back to the [summary](#-summary)

### 📜 1.4 FedRAMP Marketplace

PSSecurity needs to know whether the exact cloud service it depends on is covered by a FedRAMP certification, what that certification covers, and whether its status has changed. A provider name alone can’t answer that. The Marketplace data describes individual cloud service offerings and includes fields for certified services and services outside the minimum assessment scope.

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
| 2.2.2 | MUST | Name each match by its information type from `InformationTypes.psd1` |
| 2.2.3 | MUST NOT | Write to the searched files |
| 2.2.4 | MUST NOT | Hide findings |

> Back to the [summary](#-summary)

### 📜 2.3 FedRAMP Requirements

| # | Level | Rule |
| ----- | --- | --- |
| 2.3.1 | MUST | Install the requested FedRAMP release for local use |
| 2.3.2 | MUST | Find occurrences of a search term in the installed rules |
| 2.3.3 | MUST | Show where each occurrence appears |
| 2.3.4 | MUST | Measure the total number of occurrences |
| 2.3.5 | MUST | Return the complete rules document as JSON text when requested |

#### 🧪 2.3.6 FedRAMP rules example

The Rules feature introduces `Update-FedRAMP` and `Search-FedRAMP`.

In this example, `Update-FedRAMP` downloads the dated release ZIP, unpacks it
under `Generated/FedRAMP`, copies the formatted rules JSON and schema to
`Config/FedRAMP`, and discards the minified copies.

```powershell
Update-FedRAMP -Release '2026.11.02.01'
$result = Search-FedRAMP -Pattern '\bKSI-CED-RAT\b' -Rules
$result.Count
$result.Matches
$result.Rules
```

The search reads the configured rules file once with `Get-Content -Raw | Out-String`.
It searches the lines of that string with `Select-String -Pattern $Pattern -AllMatches`.
`-Rules` includes the full rules document as JSON text in `Rules`.
`-AsHashtable` parses that document and returns it as a hashtable in `Rules`.

> Back to the [summary](#-summary)

### 📜 2.4 FedRAMP Marketplace Requirements

| # | Level | Rule |
| ----- | --- | --- |
| 2.4.1 | MUST | Make the published FedRAMP Marketplace data available for local use |
| 2.4.2 | MUST | Find cloud service offerings by business category |
| 2.4.3 | MUST | Show the offering’s published certification status |
| 2.4.4 | MAY | Show which services the listing identifies as certified and which it identifies as outside the minimum assessment scope |
| 2.4.5 | MAY | Show recorded certification status changes for the offering |

#### 🧪 2.4.6 Marketplace category example

The Marketplace feature makes both commands advanced functions.
`Update-FedRAMP` also downloads the Marketplace data ZIP.
`Search-FedRAMP` gains Rules and Marketplace parameter sets, selected by
`-Rules` and `-Marketplace`. Both take `-Pattern`, return `Count` and
`Matches`, and include the selected document as JSON text in `Rules` or
`Marketplace`. With `-AsHashtable`, the selected document is returned as a
hashtable in the same property. The example matches the whole word `AI` or
the phrase `artificial intelligence`.

```powershell
Update-FedRAMP -Release '2026.11.02.01'
$pattern = '\bAI\b|\bartificial intelligence\b'
$result = Search-FedRAMP -Pattern $pattern -Marketplace
$result.Count
$result.Matches
$result.Marketplace

$result = Search-FedRAMP -Pattern '\bKSI-CED-RAT\b' -Rules -AsHashtable
$result.Rules['KSI']['CED']['indicators']['KSI-CED-RAT']
```

> Back to the [summary](#-summary)

## ❓ 3. Open Questions

### 📜 3.1 Get-Log

- What about syslog?
- For a later version, should we build log providers?

> Back to the [summary](#-summary)
