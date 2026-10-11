Set-StrictMode -Version Latest

if ($IsLinux) {
    function New-SecurityCertificate {
        <#
        .SYNOPSIS
            Generates certificates with mkcert on Linux.

        .PARAMETER Hostname
            Host name to certify. Defaults to the output of hostname.

        .PARAMETER Subdomains
            Optional subdomain labels to prefix to Hostname. Defaults to an empty array.

        .EXAMPLE
            New-SecurityCertificate -Hostname example.test -Subdomains api -WhatIf

            Previews certificate generation for the host and subdomain. Requires mkcert; this function is defined on Linux.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory = $false,
                HelpMessage = 'Host name to certify. Defaults to the output of hostname.')]
            [string]$Hostname = (hostname),

            [Parameter(Mandatory = $false,
                HelpMessage = 'Optional subdomain labels to prefix to Hostname. Defaults to an empty array.')]
            [string[]]$Subdomains = @()
        )

        try {
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

            return $results
        }
        catch {
            Write-Error "Certificate generation failed: $_"
        }
    }
}
