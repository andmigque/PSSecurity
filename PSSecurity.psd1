
@{
    RootModule           = '.\PSSecurity.psm1'
    ModuleVersion        = '1.5.0'
    CompatiblePSEditions = 'Core'
    GUID                 = '01a0121d-ee0e-7b97-b54f-7d7a978cf8fc'
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
            ReleaseNotes = 'Updated AGENTS.md'
        }
    }
}

