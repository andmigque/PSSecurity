using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

if ($IsLinux) {
    #### <h2 style="color: #DCA657;">New-SecurityCertificate</h2>
    ####
    function New-SecurityCertificate {
        #### Generate locally trusted TLS certificates for a hostname and optional subdomains.
        ####
        #### Supports `-WhatIf`.
        ####
        #### <b style="color: #D2A8FF;">Parameters</b>
        ####
        [CmdletBinding(SupportsShouldProcess)]
        param(
            #### - `[string]`: __Hostname__
            ####     - *Primary hostname. Defaults to the system hostname.*
            [Parameter(Mandatory = $false)]
            [string]$Hostname = (hostname),

            #### - `[string[]]`: __Subdomains__
            ####     - *Optional subdomain prefixes. Each becomes `<subdomain>.<Hostname>`.*
            [Parameter(Mandatory = $false)]
            [string[]]$Subdomains = @()
        )

        try {
            ####
            #### <b style="color: #C22514;">Throws</b>
            ####
            #### - When `mkcert` is not on PATH.
            $mkcert = Get-Command mkcert -ErrorAction SilentlyContinue
            if (-not $mkcert) {
                throw 'mkcert not found'
            }

            $results = @()

            if ($PSCmdlet.ShouldProcess($Hostname, 'Generate a locally trusted certificate')) {
                Write-Output "Generating certificate for $Hostname..."
                & mkcert $Hostname
                $results += [PSCustomObject]@{ Domain = $Hostname; Status = 'Generated' }
            }

            foreach ($subdomain in $Subdomains) {
                $fqdn = "$subdomain.$Hostname"
                if ($PSCmdlet.ShouldProcess($fqdn, 'Generate a locally trusted certificate')) {
                    Write-Output "Generating certificate for $fqdn..."
                    & mkcert $fqdn
                    $results += [PSCustomObject]@{ Domain = $fqdn; Status = 'Generated' }
                }
            }

            Write-Output 'Certificate generation complete.'

            ####
            #### <b style="color: #369FFF;">Returns</b>
            ####
            #### - `[PSCustomObject[]]`
            ####     - `[string]`: __Domain__
            ####         - *Fully qualified domain the certificate covers.*
            ####     - `[string]`: __Status__
            ####         - *`Generated`.*
            return $results
        }
        catch {
            Write-Error "Certificate generation failed: $_"
        }
    }
    ####
    #### ---
    ####
}