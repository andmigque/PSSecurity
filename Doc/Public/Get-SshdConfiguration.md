# Get-SshdConfiguration

*Gets the effective SSH daemon configuration as objects.*

## DESCRIPTION

Runs sshd -T and returns one object per line of the dump. sshd -T resolves
Include files, Match blocks, and defaults into the settings the daemon
actually enforces, so the result reflects what runs rather than what any one
file says. Keywords are lowercase, as sshd prints them. A keyword that can
repeat, such as hostkey, returns one object per value.

sshd -T reads the host private keys, so it usually needs root or an elevated
session. Throws with sshd's error output when sshd fails, for example when the
host keys can't be read or the configuration has a syntax error. When sshd
reports a missing privilege separation directory, such as /run/sshd, the error
explains how to create it.

## PARAMETERS

### -ConnectionSpec

Evaluates Match blocks for a described connection, in the sshd -C format, for
example 'user=root,host=10.0.0.5,addr=10.0.0.5'. Without it, the result covers
the global configuration only.

## EXAMPLES

### Example 1

```powershell
Get-SshdConfiguration | Where-Object -Property Keyword -EQ 'permitrootlogin'
```

Shows whether root can log in.

### Example 2

```powershell
Get-SshdConfiguration -ConnectionSpec 'user=admin,host=10.0.0.5,addr=10.0.0.5' |
    Where-Object -Property Keyword -In 'permitrootlogin', 'passwordauthentication', 'x11forwarding'
```

Shows the authentication settings that apply to one connection, after Match
blocks.

### Example 3

```powershell
Get-SshdConfiguration | Where-Object -Property Keyword -EQ 'hostkey' | Select-Object -ExpandProperty Value
```

Lists every host key file.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object per setting with
Keyword and Value.

