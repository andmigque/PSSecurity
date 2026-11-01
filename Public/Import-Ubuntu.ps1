#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Import-Ubuntu {
        <#
        .SYNOPSIS
            Imports an Ubuntu archive as a WSL 2 distribution.

        .DESCRIPTION
            Creates the installation directory, then imports the tar archive with
            wsl --import as a WSL 2 distribution. Supports -WhatIf and -Confirm. Windows
            only.

        .PARAMETER Path
            The Ubuntu tar archive to import. Defaults to .\ubuntu.tar.

        .PARAMETER InstallPath
            The directory for the distribution's virtual disk, created when missing.
            Defaults to C:\WSL\DevUbuntu.

        .PARAMETER Name
            The WSL distribution name. Defaults to DevUbuntu.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.String. The output of wsl --import.

        .EXAMPLE
            Import-Ubuntu

            Imports .\ubuntu.tar as DevUbuntu in C:\WSL\DevUbuntu.

        .EXAMPLE
            Import-Ubuntu -Path .\ubuntu.tar -InstallPath C:\WSL\BuildUbuntu -Name BuildUbuntu

            Creates the installation directory and imports the archive as BuildUbuntu.

        .EXAMPLE
            Import-Ubuntu -Name BuildUbuntu -InstallPath C:\WSL\BuildUbuntu -WhatIf

            Previews the import without creating the directory or the distribution.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([string])]
        param(
            [Parameter(HelpMessage = 'Enter the path to the Ubuntu tar archive.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path = '.\ubuntu.tar',

            [Parameter(HelpMessage = 'Enter the distribution installation directory.')]
            [ValidateNotNullOrEmpty()]
            [string]$InstallPath = 'C:\WSL\DevUbuntu',

            [Parameter(HelpMessage = 'Enter the WSL distribution name.')]
            [ValidateNotNullOrEmpty()]
            [string]$Name = 'DevUbuntu'
        )

        $tar = (Resolve-Path -Path $Path -ErrorAction Stop).Path

        if ($PSCmdlet.ShouldProcess($InstallPath, "Import $tar as WSL 2 distribution $Name")) {
            [void](New-Item -ItemType Directory -Path $InstallPath -Force)

            (wsl --import $Name $InstallPath $tar --version 2)
            if ($LASTEXITCODE -ne 0) {
                throw "Import-Ubuntu failed to import $tar as $Name."
            }
        }
    }
}
