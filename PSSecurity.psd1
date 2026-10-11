
@{
    RootModule           = 'PSSecurity.psm1'
    ModuleVersion        = '1.9.0'
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
            ReleaseNotes = @'
- Added Get-SudoersAudit to audit /etc/sudoers and sudoers.d includes for passwordless and wildcard grants.
- Added Get-SshdConfiguration to parse the effective sshd -T dump into one record per keyword on Windows, Linux, and macOS.
- Replaced the custom encryption commands with Protect-Item and Unprotect-Item, backed by Windows EFS.
- Added Remove-App and Remove-ProvisionedApp for administrator-approved Windows AppX removal.
- Moved module settings to Config/Setting.psd1 and expanded hash-index configuration.
- Updated dependency installation and documentation to use PSResourceGet.
- Renamed the build file and aligned its lifecycle task names with project policy.
'@
        }
    }
}
