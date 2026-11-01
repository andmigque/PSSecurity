# Install-Sftp

*Installs the Windows OpenSSH server as a chrooted SFTP drop point.*

## DESCRIPTION

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

## PARAMETERS

### -InterfaceAlias

The network interface that accepts SFTP connections, such as 'Ethernet 3'.

### -LocalAddress

The address on that interface that accepts SFTP connections.

### -RemoteAddress

The client addresses allowed to connect.

## EXAMPLES

### Example 1

```powershell
Install-Sftp -InterfaceAlias 'Ethernet 3' -LocalAddress 10.177.1.10 -RemoteAddress 192.168.177.138 -WhatIf
```

Previews the installation.

### Example 2

```powershell
$sftpParams = @{
    InterfaceAlias = 'Ethernet 3'
    LocalAddress   = '10.177.1.10'
    RemoteAddress  = '192.168.177.138', '192.168.177.139'
}
Install-Sftp @sftpParams
```

Installs the SFTP server and allows two clients to connect.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. The Name, Status, and StartType of
the sshd service.

