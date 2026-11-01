#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Install-Sftp {
        <#
        .SYNOPSIS
            Installs the Windows OpenSSH server as a chrooted SFTP drop point.

        .DESCRIPTION
            Installs the OpenSSH.Server Windows capability, sets the sshd service to start
            automatically as LocalSystem from System32\OpenSSH, and copies sshd_config and
            banner.txt from Config/Sshd to C:\ProgramData\ssh. The config confines the
            sftp-service account to SFTP in C:\sftp-service, landing in its ingest
            directory, which this function creates. The sftp-service account must already
            exist.

            Generates any missing host keys, validates the config with sshd -t, then
            replaces the default OpenSSH firewall rule with one that only allows TCP 22 on
            one interface and address, from the given remote addresses, on the Private
            profile. Starts sshd last, after every check has passed.

            Requires an elevated session. Supports -WhatIf and -Confirm. Windows only.

        .PARAMETER InterfaceAlias
            The network interface that accepts SFTP connections, such as 'Ethernet 3'.

        .PARAMETER LocalAddress
            The address on that interface that accepts SFTP connections.

        .PARAMETER RemoteAddress
            The client addresses allowed to connect.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. The Name, Status, and StartType of
            the sshd service.

        .EXAMPLE
            Install-Sftp -InterfaceAlias 'Ethernet 3' -LocalAddress 10.177.1.10 -RemoteAddress 192.168.177.138 -WhatIf

            Previews the installation.

        .EXAMPLE
            $sftpParams = @{
                InterfaceAlias = 'Ethernet 3'
                LocalAddress   = '10.177.1.10'
                RemoteAddress  = '192.168.177.138', '192.168.177.139'
            }
            Install-Sftp @sftpParams

            Installs the SFTP server and allows two clients to connect.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory, HelpMessage = 'Enter the network interface that accepts SFTP connections.')]
            [ValidateNotNullOrEmpty()]
            [string]$InterfaceAlias,

            [Parameter(Mandatory, HelpMessage = 'Enter the local address that accepts SFTP connections.')]
            [ValidateNotNullOrEmpty()]
            [string]$LocalAddress,

            [Parameter(Mandatory, HelpMessage = 'Enter the client addresses allowed to connect.')]
            [ValidateNotNullOrEmpty()]
            [string[]]$RemoteAddress
        )

        Assert-Administrator

        $configSource = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Config' -AdditionalChildPath 'Sshd'
        $openSshPath = Join-Path -Path $env:WINDIR -ChildPath 'System32\OpenSSH'
        $ruleName = 'PSSecurity SFTP'

        if (-not $PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Install SFTP on $InterfaceAlias $LocalAddress for $($RemoteAddress -join ', ')")) {
            return
        }

        $ErrorActionPreference = 'Stop'

        [void](Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0')

        $sshdService = Get-Service -Name sshd
        if ($sshdService.Status -eq 'StartPending') {
            $sshdService.WaitForStatus('Running', [System.TimeSpan]::FromSeconds(60))
        }
        Stop-Service -Name sshd
        Set-Service -Name sshd -StartupType Automatic

        # Set-Service cannot change the binary path, so sc.exe points the service at System32.
        (sc.exe config sshd binPath= "`"$openSshPath\sshd.exe`"" obj= LocalSystem) | ForEach-Object { Write-Verbose -Message $_ }
        if ($LASTEXITCODE -ne 0) {
            throw 'Install-Sftp could not configure the sshd service executable and identity.'
        }

        [void](New-Item -ItemType Directory -Path C:\ProgramData\ssh, C:\sftp-service\ingest -Force)
        Copy-Item -LiteralPath "$configSource\sshd_config", "$configSource\banner.txt" -Destination C:\ProgramData\ssh -Force

        (& "$openSshPath\ssh-keygen.exe" -A) | ForEach-Object { Write-Verbose -Message $_ }
        if ($LASTEXITCODE -ne 0) {
            throw 'Install-Sftp failed to generate the host keys.'
        }

        (& "$openSshPath\sshd.exe" -t) | ForEach-Object { Write-Verbose -Message $_ }
        if ($LASTEXITCODE -ne 0) {
            throw 'Install-Sftp found sshd_config invalid; sshd -t failed.'
        }

        Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue | Disable-NetFirewallRule
        Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule

        $firewallParams = @{
            Name                = $ruleName
            DisplayName         = $ruleName
            Direction           = 'Inbound'
            Action              = 'Allow'
            Enabled             = 'True'
            Profile             = 'Private'
            InterfaceAlias      = $InterfaceAlias
            LocalAddress        = $LocalAddress
            RemoteAddress       = $RemoteAddress
            Protocol            = 'TCP'
            LocalPort           = 22
            Service             = 'sshd'
            EdgeTraversalPolicy = 'Block'
        }
        [void](New-NetFirewallRule @firewallParams)

        Start-Service -Name sshd
        Get-Service -Name sshd | Select-Object -Property Name, Status, StartType
    }
}
