@{
    RootModule           = 'PSSecurity.psm1'
    ModuleVersion        = '2.0.0'
    CompatiblePSEditions = 'Core'
    GUID                 = '01a0121d-ee0e-7b97-b54f-7d7a978cf8fc'
    Author               = 'Andres Quesada'
    CompanyName          = 'Quesada Works'
    Copyright            = '(c) 2026 Andres Quesada. Released under the MIT License.'
    Description          = 'A cross-platform PowerShell module for auditing and hardening Windows and Linux.'
    PowerShellVersion    = '7.4'

    # Every public function. Platform-specific functions are defined only on their
    # platform, so each system exports the subset that exists there.
    FunctionsToExport    = @(
        'Add-UnixFileMode'
        'Compress-FileTree'
        'Convert-CommentHelpToMarkdown'
        'Deploy-LinuxConfiguration'
        'Deploy-PSProfile'
        'Get-AclItem'
        'Get-ApplicationSignatureAudit'
        'Get-ScheduledTaskAudit'
        'Get-SshdConfiguration'
        'Get-SudoersAudit'
        'Get-UacConfiguration'
        'Get-UnixFileMode'
        'Import-Ubuntu'
        'Install-AzureDevOpsAgent'
        'Install-DpkgPwsh'
        'Invoke-Sudo'
        'Measure-OwnerAnomaly'
        'New-LocalAdminUser'
        'New-SecurityCertificate'
        'New-WindowsUserProfile'
        'Protect-Item'
        'Remove-App'
        'Remove-ProvisionedApp'
        'Search-PatternInFile'
        'Set-AclItemOwner'
        'Set-LinuxFilePermission'
        'Set-UacConsentOnly'
        'Set-UacRequirePassword'
        'Unprotect-Item'
        'Write-DirectoryHash'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData          = @{
        PSData = @{
            Tags         = @(
                'Security', 'Hardening', 'Audit', 'Compliance', 'NIST', 'NIST800-171', 'CUI', 'CIS',
                'ACL', 'Permissions', 'Ownership', 'UAC', 'Authenticode', 'CodeSigning', 'EFS', 'Encryption',
                'ScheduledTask', 'AppX', 'Bloatware', 'Hash', 'FileIntegrity', 'FedRAMP',
                'Sudo', 'Sudoers', 'SUID', 'Sysctl', 'Kernel', 'SSH', 'OpenSSH', 'Sshd', 'SFTP',
                'Certificate', 'WSL', 'AzureDevOps', 'DevSecOps', 'SysAdmin', 'CrossPlatform',
                'Windows', 'Linux', 'PSEdition_Core'
            )
            LicenseUri   = 'https://github.com/andmigque/PSSecurity/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/andmigque/PSSecurity'
            ReleaseNotes = @'
2.0.0

- Linux hardening is now configuration files in Config/Linux, deployed by Deploy-LinuxConfiguration.
- Set-SysctlHardening, Set-ModprobeBlacklist, and Set-CoreDumpPolicy are removed.
- Set-LinuxFilePermission applies Config/LinuxFilePermission.psd1.
- Set-CronPermission and Set-HomeDirectoryPermission are removed.
- Set-LoginDefPolicy is removed: /etc/login.defs differs by distribution.
- Get-SuidBinary, Get-WorldWritableFile, and Set-StickyBitOnWorldWritable are replaced by Get-UnixFileMode and Add-UnixFileMode.
- Get-SshdConfiguration and Get-SudoersAudit return one object per setting or rule instead of a report object.
- Install-DpkgPwsh76 is renamed Install-DpkgPwsh.
- Get-ApplicationSignatureAudit: -Throttle is renamed -ThrottleLimit.
- New-SecurityCertificate: -Subdomains is renamed -Subdomain.
- New-WindowsUserProfile: -IsAdmin is a switch.
- Removed Compare-MegaHash, Join-MegaHash, Install-Sftp, the Windows SFTP configuration and banner, and the Azure Pipelines definitions for building and hardening the WSL image.

Changes
- Every public function has full comment-based help, OutputType, and a platform check.
- Linux functions work on any distribution and use no distribution-specific tools.
- Get-ApplicationSignatureAudit no longer installs ThreadJob from the PowerShell Gallery.
- State-changing functions support -WhatIf and -Confirm.
'@
        }
    }
}
