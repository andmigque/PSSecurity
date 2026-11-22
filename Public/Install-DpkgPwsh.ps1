#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Install-DpkgPwsh {
        <#
        .SYNOPSIS
            Installs PowerShell 7.6.6 from the GitHub .deb package.

        .DESCRIPTION
            Downloads the pinned PowerShell 7.6.6 amd64 .deb package to /tmp with wget,
            installs it with dpkg, then lets apt install the dependencies the package
            needs and finish the installation. The package is deleted afterward.

            dpkg is expected to report unmet dependencies, which the apt steps that
            follow repair, so only the download and apt steps stop the function.

            Runs sudo, so it can prompt for a password. Supports -WhatIf and -Confirm.
            Debian and Ubuntu only.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.String. The output of wget, dpkg, and apt-get.

        .EXAMPLE
            Install-DpkgPwsh

            Installs PowerShell 7.6.6.

        .EXAMPLE
            Install-DpkgPwsh -WhatIf

            Previews the installation without downloading the package.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([string])]
        param()

        $debName = 'powershell_7.6.6-1.deb_amd64.deb'
        $debPath = "/tmp/$debName"
        $debUri = "https://github.com/PowerShell/PowerShell/releases/download/v7.6.6/$debName"

        if ($PSCmdlet.ShouldProcess($debUri, 'Download and install PowerShell 7.6.6')) {
            (wget -q -O $debPath $debUri)
            if ($LASTEXITCODE -ne 0) {
                throw "Install-DpkgPwsh failed to download $debUri."
            }

            (sudo dpkg -i $debPath)

            (sudo apt-get install -f)
            if ($LASTEXITCODE -ne 0) {
                throw 'Install-DpkgPwsh failed to resolve the PowerShell package dependencies.'
            }

            (sudo apt-get install -y powershell)
            if ($LASTEXITCODE -ne 0) {
                throw 'Install-DpkgPwsh failed to install PowerShell.'
            }

            Remove-Item -LiteralPath $debPath -Force
        }
    }
}
