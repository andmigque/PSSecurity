
function Install-Sftp {
    # $ErrorActionPreference = 'Stop'

    # Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0'

    # $openSshPath = "$env:WINDIR\System32\OpenSSH"

    # $sshdService = Get-Service -Name sshd
    # if ($sshdService.Status -eq 'StartPending') {
    #     $sshdService.WaitForStatus('Running', [TimeSpan]::FromSeconds(60))
    # }
    # Stop-Service -Name sshd
    # Set-Service -Name sshd -StartupType Automatic
    # sc.exe config sshd binPath= ('"' + $openSshPath + '\sshd.exe"') obj= LocalSystem
    # if ($LASTEXITCODE -ne 0) { throw 'Could not configure the sshd service executable and identity.' }


    # New-Item -ItemType Directory -Path C:\ProgramData\ssh -Force
    # New-Item -ItemType Directory -Path C:\sftp-service\ingest -Force

    # Copy-Item "$PSScriptRoot\sshd_config" C:\ProgramData\ssh\sshd_config -Force
    # Copy-Item "$PSScriptRoot\banner.txt" C:\ProgramData\ssh\banner.txt -Force

    # & "$openSshPath\ssh-keygen.exe" -A
    # if ($LASTEXITCODE -ne 0) { throw 'Host key generation failed.' }
    # & "$openSshPath\sshd.exe" -t
    # if ($LASTEXITCODE -ne 0) { throw 'sshd_config validation failed.' }

    # Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue |
    #     Disable-NetFirewallRule

    # Get-NetFirewallRule -Name 'SFTP NIC 2 private IP' -ErrorAction SilentlyContinue |
    #     Remove-NetFirewallRule

    # New-NetFirewallRule -Name 'SFTP NIC 2 private IP' `
    #     -DisplayName 'SFTP NIC 2 private IP' `
    #     -Direction Inbound `
    #     -Action Allow `
    #     -Enabled True `
    #     -Profile Private `
    #     -InterfaceAlias 'Ethernet 3' `
    #     -LocalAddress 10.177.1.10 `
    #     -RemoteAddress 192.168.177.138 `
    #     -Protocol TCP `
    #     -LocalPort 22 `
    #     -Service sshd `
    #     -EdgeTraversalPolicy Block

    # Start-Service -Name sshd
}