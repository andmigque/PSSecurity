Set-StrictMode -Version Latest

$script:Generated = Join-Path -Path $PSScriptRoot -ChildPath 'Generated'
$script:SourceFolders = @(
    (Join-Path -Path $PSScriptRoot -ChildPath 'Public')
    (Join-Path -Path $PSScriptRoot -ChildPath 'Private')
)

#### <h1 style="color: #DCA657;">🎆 os.build</h1>
####
#### > Invoke-Build tasks for the module
####
#### ---

#### <h2 style="color: #DCA657;">test_pester</h2>
####
#### Runs every file under `Test`.
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
#### Executes the script rules and writes the report to `Generated`.
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
#### Regenerates `HashIndex.md` and `HashIndex.json` across the repository.
####
Add-BuildTask write_directory_hashes {
    $moduleFile = Join-Path -Path "$PSScriptRoot" -ChildPath 'PSSecurity.psm1'
    Import-Module $moduleFile
    Write-DirectoryHash $PSScriptRoot
}

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

Add-BuildTask convert_to_sharpdown {
    Import-Module Sharpdown
    ConvertTo-SharpDown -Language PowerShell -Path .\ -OutPath .\Doc\ -Recurse
}

Add-BuildTask get_application_authenticode_audit {
    $moduleFile = Join-Path -Path "$PSScriptRoot" -ChildPath 'PSSecurity.psm1'
    Import-Module $moduleFile

    Get-ApplicationSignatureAudit | ConvertTo-Csv | Out-File -FilePath .\Generated\AppSigAudit.csv
}

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

Add-BuildTask . test_ps_script_analyzer, test_pester, write_directory_hashes, convert_to_sharpdown
