# New-SecurityCertificate

*Generates locally trusted certificates with mkcert.*

## DESCRIPTION

Runs mkcert once for the host name and once for each subdomain, prefixed to
the host name. mkcert writes each certificate and key to the current
directory. mkcert's own output is written to the verbose stream.

Requires mkcert. Supports -WhatIf and -Confirm. Linux only.

## PARAMETERS

### -Hostname

The host name to certify. Defaults to the output of hostname.

### -Subdomain

Subdomain labels to prefix to the host name, such as api for
api.example.test. One certificate is generated for each.

## EXAMPLES

### Example 1

```powershell
New-SecurityCertificate
```

Generates a certificate for this computer's host name.

### Example 2

```powershell
New-SecurityCertificate -Hostname example.test -Subdomain api, www -Verbose
```

Generates certificates for example.test, api.example.test, and
www.example.test, and shows mkcert's output.

### Example 3

```powershell
New-SecurityCertificate -Hostname example.test -Subdomain api -WhatIf
```

Previews certificate generation for the host and subdomain.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object per generated
certificate, with the domain and status. Nothing is returned for -WhatIf.

