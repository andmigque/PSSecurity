Set-Alias -Name 'psdatafile' -Value Import-PowerShellDataFile
Set-Alias -Name 'jp' -Value Join-Path
Set-Alias -Name 'analyze' -Value Invoke-ScriptAnalyzer
Set-Alias -Name 'tstModManifest' -Value Test-ModuleManifest
Set-Alias -Name 'compObj' -Value Compare-Object

$script:scriptRootPath = $PSScriptRoot
$script:moduleRootPath = Split-Path -Path $scriptRootPath -Parent
$script:testSettingFilePath = (jp -Path $scriptRootPath -ChildPath 'Setting.psd1')
$script:settings = psdatafile -Path $testSettingFilePath

$script:manifestFile = $settings.ModuleRootRelative.ManifestFile
$script:manifestFilePath = (jp -Path $moduleRootPath -ChildPath $manifestFile)
$script:publicFunctionPath = (jp -Path $moduleRootPath -ChildPath $settings.ModuleRootRelative.PublicFunctions)
$script:privateFunctionPath = (jp -Path $moduleRootPath -ChildPath $settings.ModuleRootRelative.PrivateFunctions)
$script:configDirectoryPath = (jp -Path $moduleRootPath -ChildPath $settings.ModuleRootRelative.ConfigDirectory)
$script:analyzerSettingFilePath = (jp -Path $moduleRootPath -ChildPath $settings.ModuleRootRelative.AnalyzerSettingFile)
$script:configSettingFilePath = (jp -Path $moduleRootPath -ChildPath $settings.ModuleRootRelative.ConfigSettingFile)
$script:configSettings = psdatafile -Path $configSettingFilePath

function Test-PSSecurityManifest {
    <#
    .DESCRIPTION
    This function should check PSSecurity.psd1 before a release.
    It should confirm the manifest parses and that FunctionsToExport lists exactly the functions in Public/.

    #>
    $manifest = tstModManifest -Path $script:manifestFilePath
    $public = (gci -Path $script:publicFunctionPath).BaseName
    -not (compObj -ReferenceObject $public -DifferenceObject @($manifest.ExportedFunctions.Keys))
}

function Test-ReleaseBranchNameGitTagMatch {
    <#
    .DESCRIPTION
    This confirms that the release branch name and the git tag name are the same version.

    .NOTES
    This function is gloriously minimal on purpose.
    We should think about binary dependencies?
    Where in the app do we declare them? Assert they exist?
    #>
    $scrptRoot = $script:scriptRootPath
    (git -C $scrptRoot branch --show-current) -eq "release/$(git -C $scrptRoot tag --points-at HEAD)"
}

function Test-ScriptAnalyzerPublicPrivate {
    <#
    .DESCRIPTION
    This function should run PSScriptAnalyzer with the repository settings against Public/ and Private/
    only, the code that actually ships.

    The problem: running the analyzer on the whole repository mixes the shipped code with Doc/ and
    Skill/ examples that aren't published. It also crashes on some files when it loads
    PSScriptAnalyzerSettings.psd1, so the result isn't a clear pass or fail for the release.

    .NOTES
    Yes...
    #>
    -not ($script:publicFunctionPath, $script:privateFunctionPath | % { analyze -Path $_ -Settings $script:analyzerSettingFilePath })
}


function Test-PrePublishSuite {
    $result = @(
        Test-PSSecurityManifest
        Test-ReleaseBranchNameGitTagMatch
        Test-ScriptAnalyzerPublicPrivate
    )
    Write-Host 'Passed : ' -NoNewline
    Write-Host @($result -eq $true).Count -ForegroundColor Green -NoNewline
    Write-Host ' , Failed : ' -NoNewline
    Write-Host @($result -eq $false).Count -ForegroundColor Red
}