
@{
    RootModule           = 'PSSecurity.psm1'
    ModuleVersion        = '1.3.0'
    CompatiblePSEditions = 'Core'
    GUID                 = '1f60f975-319a-4e4f-94cc-dd33d510085a'
    Author               = 'Andres Quesada'
    CompanyName          = 'Quesada Works'
    Copyright            = '(c) 2026 Andres Quesada. Released under the MIT License.'
    Description          = 'PowerShell security toolkit with hashing, encryption, parallelism, and more'
    PowerShellVersion    = '7.4'
    CmdletsToExport      = @()
    AliasesToExport      = @()
    PrivateData          = @{
        PSData = @{
            Tags         = 'Security', 'Encryption', 'Hashing', 'FileIntegrity', 'ACL', 'UAC',
            'Authenticode', 'Windows', 'PSEdition_Core'
            LicenseUri   = 'https://github.com/andmigque/PSSecurity/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/andmigque/PSSecurity'
            ReleaseNotes = 'Initial Release'
        }
    }
}

