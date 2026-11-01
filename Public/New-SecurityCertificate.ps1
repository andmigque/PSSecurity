#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function New-SecurityCertificate {
        <#
        .SYNOPSIS
            Generates locally trusted certificates with mkcert.

        .DESCRIPTION
            Runs mkcert once for the host name and once for each subdomain, prefixed to
            the host name. mkcert writes each certificate and key to the current
            directory. mkcert's own output is written to the verbose stream.

            Requires mkcert. Supports -WhatIf and -Confirm. Linux only.

        .PARAMETER Hostname
            The host name to certify. Defaults to the output of hostname.

        .PARAMETER Subdomain
            Subdomain labels to prefix to the host name, such as api for
            api.example.test. One certificate is generated for each.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object per generated
            certificate, with the domain and status. Nothing is returned for -WhatIf.

        .EXAMPLE
            New-SecurityCertificate

            Generates a certificate for this computer's host name.

        .EXAMPLE
            New-SecurityCertificate -Hostname example.test -Subdomain api, www -Verbose

            Generates certificates for example.test, api.example.test, and
            www.example.test, and shows mkcert's output.

        .EXAMPLE
            New-SecurityCertificate -Hostname example.test -Subdomain api -WhatIf

            Previews certificate generation for the host and subdomain.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(HelpMessage = 'Host name to certify. Defaults to the output of hostname.')]
            [ValidateNotNullOrEmpty()]
            [string]$Hostname = (hostname),

            [Parameter(HelpMessage = 'Subdomain labels to prefix to Hostname.')]
            [string[]]$Subdomain = @()
        )

        if (-not (Get-Command -Name mkcert -CommandType Application -ErrorAction SilentlyContinue)) {
            throw 'New-SecurityCertificate requires mkcert, which was not found.'
        }

        $domains = @($Hostname) + @($Subdomain | ForEach-Object { "$_.$Hostname" })

        foreach ($domain in $domains) {
            if ($PSCmdlet.ShouldProcess($domain, 'Generate a locally trusted certificate')) {
                (mkcert $domain) | ForEach-Object { Write-Verbose -Message $_ }
                if ($LASTEXITCODE -ne 0) {
                    throw "New-SecurityCertificate failed to generate a certificate for $domain."
                }

                [PSCustomObject]@{
                    Domain = $domain
                    Status = 'Generated'
                }
            }
        }
    }
}
