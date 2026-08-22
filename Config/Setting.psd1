@{
    HashIndexAlgorithm         = 'SHA256'

    HashIndexInclude           = @(
        '*.md'
        '*.ps1'
        '*.psm1'
        '*.cs'
        '*.psd1'
        '*.ts'
        '*.sql'
        '*.json'
        '*.csv'
        '*.zip'
        '*.js'
        '*.cshtml'
    )

    HashIndexExclude           = @(
        'bin'
        'obj'
        'node_modules'
        '.git'
        'Generated'
        '.vscode'
    )

    DependencyPromptAnswered   = $true

    PSSecurityRuntimeModules   = @(
        @{
            ModuleName    = 'BurntToast'
            ModuleVersion = '1.1.0'
        }
    )

    PSSecurityBuildtimeModules = @(
        @{
            ModuleName    = 'InvokeBuild'
            ModuleVersion = '5.14.23'
        }
        @{
            ModuleName    = 'Pester'
            ModuleVersion = '6.0.1'
        }
        @{
            ModuleName    = 'PSScriptAnalyzer'
            ModuleVersion = '1.25.0'
        }
    )

    AppxPackages               = @(
        'Microsoft.XboxSpeechToTextOverlay_1.97.17002.0_x64__8wekyb3d8bbwe'
        'Microsoft.BingWeather_4.54.63045.0_x64__8wekyb3d8bbwe'
        'MSTeams_26163.405.4842.717_x64__8wekyb3d8bbwe'
        'Clipchamp.Clipchamp_4.5.10920.0_x64__yxz26nhyzhsrt'
        'Microsoft.AIFabric.CBS.1.6_1.6.951.100_x64__8wekyb3d8bbwe'
        'Microsoft.XboxGamingOverlay_7.326.7271.0_x64__8wekyb3d8bbwe'
        'Microsoft.PowerAutomateDesktop_1.0.2117.0_x64__8wekyb3d8bbwe'
        'Microsoft.BingNews_4.56.21872.0_x64__8wekyb3d8bbwe'
        'Microsoft.Todos_0.176.7601.0_x64__8wekyb3d8bbwe'
        'Microsoft.WindowsFeedbackHub_2.2607.301.0_x64__8wekyb3d8bbwe'
        'Microsoft.GetHelp_10.2409.42162.0_x64__8wekyb3d8bbwe'
        'Microsoft.YourPhone_1.26071.164.0_x64__8wekyb3d8bbwe'
        'MicrosoftWindows.CrossDevice_0.26071.84.0_x64__cw5n1h2txyewy'
        'Microsoft.OutlookForWindows_1.2026.811.200_x64__8wekyb3d8bbwe'
        'Microsoft.Windows.DevHome_0.2101.858.0_x64__8wekyb3d8bbwe'
    )

    ProvisionedAppxPackages    = @(
        'Clipchamp.Clipchamp_4.5.10920.0_neutral_~_yxz26nhyzhsrt'
        'Microsoft.BingNews_4.7.6002.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.BingSearch_2022.1.43.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.BingWeather_4.54.63045.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.GamingApp_2608.1001.17.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.GetHelp_10.2409.42162.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.MicrosoftOfficeHub_2026.811.1536.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.MicrosoftSolitaireCollection_4.26.7290.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.MicrosoftStickyNotes_6.1.4.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.OutlookForWindows_1.2026.811.200_x64__8wekyb3d8bbwe'
        'Microsoft.PowerAutomateDesktop_11.2607.187.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.Todos_2.176.7601.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.Windows.DevHome_0.2101.858.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.WindowsAlarms_2021.2606.11.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.WindowsCalculator_2021.2606.0.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.WindowsFeedbackHub_2.2607.301.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.WindowsSoundRecorder_2021.2606.0.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.WindowsStore_22607.1401.3.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.WindowsTerminal_3001.24.11911.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.Xbox.TCUI_1.24.10001.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.XboxGamingOverlay_7.326.7271.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.XboxIdentityProvider_12.130.16001.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.XboxSpeechToTextOverlay_1.97.17002.0_neutral_~_8wekyb3d8bbwe'
        'Microsoft.YourPhone_1.26071.164.0_neutral_~_8wekyb3d8bbwe'
        'MicrosoftCorporationII.QuickAssist_2024.309.159.0_neutral_~_8wekyb3d8bbwe'
        'MicrosoftWindows.CrossDevice_1.26071.84.0_neutral_~_cw5n1h2txyewy'
        'MSTeams_26163.405.4842.717_x64__8wekyb3d8bbwe'
    )
}
