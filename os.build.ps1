Set-StrictMode -Version Latest

$script:Generated = Join-Path -Path $PSScriptRoot -ChildPath 'Generated'
$script:SourceFolders = @(
    (Join-Path -Path $PSScriptRoot -ChildPath 'Public')
    (Join-Path -Path $PSScriptRoot -ChildPath 'Private')
)

#### <h1 style="color: #DCA657;">🎆 os.build</h1>
####
#### > Defines the validation, documentation, integrity, and audit workflows for PSSecurity.
####
#### Run the default build from the repository root:
####
#### ```powershell
#### Invoke-Build -File .\os.build.ps1
#### ```
####
#### Run one task by name when an agent needs a specific artifact or check:
####
#### ```powershell
#### Invoke-Build <task-name> -File .\os.build.ps1
#### ```
####
#### ---
####
#### <h2 style="color: #DCA657;">Build context</h2>
####
#### The build expects the repository root to be the current directory because several task
#### paths are relative. Generated reports are written beneath `Generated`. Pester coverage is
#### measured against the PowerShell files in `Public` and `Private`.
####
#### <h2 style="color: #DCA657;">Default pipeline</h2>
####
#### The default task runs these dependencies in the declared order:
####
#### | Task | Result |
#### | --- | --- |
#### | `test_ps_script_analyzer` | Analyze the repository and write the findings report. |
#### | `test_pester` | Run the test suite and write test-result and coverage reports. |
#### | `write_directory_hashes` | Regenerate the repository hash indexes. |
#### | `convert_to_sharpdown` | Regenerate Markdown documentation from source comments. |
####
#### Integrity comparison and security audits are on-demand tasks. They do not run as part of
#### the default pipeline.
####
#### ---

#### <h2 style="color: #DCA657;">test_pester</h2>
####
#### Runs Pester from the repository root with plain-text console rendering. The task enables
#### pass-through results, test-result output, and code coverage for `Public` and `Private`.
####
#### | Artifact | Contents |
#### | --- | --- |
#### | `Generated/PesterTests.xml` | Test execution results. |
#### | `Generated/PesterCodeCoverage.xml` | Coverage results for the module source folders. |
####

Add-BuildTask test_pester {
    $originalRendering = $PSStyle.OutputRendering
    $PSStyle.OutputRendering = 'PlainText'
    Import-Module Pester -ErrorAction SilentlyContinue
    # get default from static property
    $configuration = [PesterConfiguration]::Default
    # PassThru is what makes Invoke-Pester hand back the result object we assert on
    $configuration.Run.PassThru = $true
    $configuration.TestResult.Enabled = $true
    # adding properties & discover via intellisense
    $configuration.TestResult.OutputPath = Join-Path -Path .\Generated -ChildPath 'PesterTests.xml'
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.OutputPath = Join-Path -Path .\Generated -ChildPath 'PesterCodeCoverage.xml'
    $configuration.CodeCoverage.Path = $script:SourceFolders
    [void](New-Item -Path .\Generated -ItemType Directory -Force)
    Invoke-Pester -Configuration $configuration
    $PSStyle.OutputRendering = $originalRendering
}

####
#### <h2 style="color: #DCA657;">test_ps_script_analyzer</h2>
####
#### Runs PSScriptAnalyzer recursively with `PSScriptAnalyzerSettings.psd1`. Suppressed findings
#### remain visible in the report. The task writes the findings to
#### `Generated/ScriptAnalyzer.txt` and also returns them to the build output.
####
Add-BuildTask test_ps_script_analyzer {
    Import-Module -Name PSScriptAnalyzer -ErrorAction SilentlyContinue
    New-Item -Path 'Generated' -ItemType Directory -ErrorAction SilentlyContinue
    $filePath = '.\PSScriptAnalyzerSettings.psd1'
    $scriptAnalysis = Invoke-ScriptAnalyzer -Path .\ -Recurse -IncludeSuppressed -Settings $filePath -ErrorAction SilentlyContinue
    $generatedPath = (Join-Path -Path "$PSScriptRoot" -ChildPath 'Generated' -AdditionalChildPath 'ScriptAnalyzer.txt')
    $scriptAnalysis | Out-File -FilePath $generatedPath
    $scriptAnalysis
}

####
#### <h2 style="color: #DCA657;">write_directory_hashes</h2>
####
#### Imports PSSecurity and rebuilds `HashIndex.md` and `HashIndex.json` from the current
#### repository contents. This task creates a new baseline; it does not compare against the
#### previous index.
####
Add-BuildTask write_directory_hashes {
    $moduleFile = Join-Path -Path "$PSScriptRoot" -ChildPath 'PSSecurity.psm1'
    Import-Module $moduleFile
    Write-DirectoryHash $PSScriptRoot
}

#### <h2 style="color: #DCA657;">confirm_hash_index_integrity</h2>
####
#### Checks the current repository against the existing `HashIndex.json` baseline:
####
#### 1. Move the existing JSON index to the system temporary directory.
#### 2. Import PSSecurity and generate a new index from the repository.
#### 3. Compare the old and new JSON files line by line.
#### 4. Remove the temporary baseline when the comparison completes.
####
#### This task is on demand and is not part of the default pipeline.
####
#### <b style="color: #C22514;">Throws</b>
####
#### - When `HashIndex.json` does not exist before the check.
#### - When the regenerated index differs from the existing baseline.
####
Add-BuildTask confirm_hash_index_integrity {
    if (-not (Test-Path -Path .\HashIndex.json)) {
        throw 'Existing Hash Index is required to compare against.'
    }
    New-Item -Path 'Generated' -ItemType Directory -ErrorAction SilentlyContinue
    Move-Item -Path .\HashIndex.json -Destination "$($env:TEMP)" -Force
    $moduleFile = Join-Path -Path "$PSScriptRoot" -ChildPath 'PSSecurity.psm1'
    Import-Module $moduleFile
    Write-DirectoryHash $PSScriptRoot
    $difference = Compare-Object (Get-Content "$($env:TEMP)\HashIndex.json") (Get-Content .\HashIndex.json)
    if ($difference) {
        $difference
        Remove-Item "$($env:TEMP)\HashIndex.json" -Force
        throw 'Integrity violation. Hash indexes do not match.'
    }
    Remove-Item "$($env:TEMP)\HashIndex.json" -Force
}

#### <h2 style="color: #DCA657;">convert_to_sharpdown</h2>
####
#### Imports Sharpdown and recursively renders the repository's PowerShell documentation into
#### `Doc`. Generated Markdown is derived from the Sharpdown comments in the source files and
#### should not be edited directly.
####
Add-BuildTask convert_to_sharpdown {
    Import-Module Sharpdown
    ConvertTo-SharpDown -Language PowerShell -Path .\ -OutPath .\Doc\ -Recurse
}

#### <h2 style="color: #DCA657;">get_application_authenticode_audit</h2>
####
#### Imports PSSecurity, audits application signatures, and writes the results as CSV to
#### `Generated/AppSigAudit.csv`. This task is on demand and is not part of the default pipeline.
####
Add-BuildTask get_application_authenticode_audit {
    $moduleFile = Join-Path -Path "$PSScriptRoot" -ChildPath 'PSSecurity.psm1'
    Import-Module $moduleFile

    Get-ApplicationSignatureAudit | ConvertTo-Csv | Out-File -FilePath .\Generated\AppSigAudit.csv
}

#### <h2 style="color: #DCA657;">get_acl_item_owner_anomaly_audit</h2>
####
#### Recursively reads ACL information beneath the current user's home directory, measures owner
#### anomalies, groups those anomalies by owner, and writes the grouped JSON to
#### `Generated/AclItemOwnerAnomaly.json`. Hidden items are included. This task is on demand and
#### is not part of the default pipeline.
####
Add-BuildTask get_acl_item_owner_anomaly_audit {
    $moduleFile = Join-Path -Path "$PSScriptRoot" -ChildPath 'PSSecurity.psm1'
    Import-Module $moduleFile
    Get-ChildItem -Path (Resolve-Path '~') -Recurse -Force |
        ForEach-Object { $_.FullName | Get-AclItem } |
        Measure-OwnerAnomaly | Select-Object -ExpandProperty Anomalies |
        Group-Object -Property Owner | ConvertTo-Json -Depth 10 | Set-Content .\Generated\AclItemOwnerAnomaly.json
}

####
#### ---
####
#### <h2 style="color: #DCA657;">Default task</h2>
####
#### The `.` task is the entry point used when `Invoke-Build` is called without a task name. Its
#### dependency list defines the default pipeline shown at the top of this document.
####

Add-BuildTask . test_ps_script_analyzer, test_pester, write_directory_hashes, convert_to_sharpdown
