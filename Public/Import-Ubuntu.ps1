Set-StrictMode -Version Latest

function Import-Ubuntu {
    <#
    .SYNOPSIS
        Imports an Ubuntu archive as a WSL 2 distribution.

    .PARAMETER Path
        Ubuntu tar archive to import. Defaults to .\ubuntu.tar.

    .PARAMETER InstallPath
        Distribution installation directory. Defaults to C:\WSL\DevUbuntu.

    .PARAMETER Name
        WSL distribution name. Defaults to DevUbuntu.

    .EXAMPLE
        Import-Ubuntu -Path .\ubuntu.tar -InstallPath C:\WSL\BuildUbuntu -Name BuildUbuntu

        Creates the installation directory and imports the archive as BuildUbuntu.
    #>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = 'Enter the path to the Ubuntu tar archive.')]
        [string]$Path = '.\ubuntu.tar',

        [Parameter(HelpMessage = 'Enter the distribution installation directory.')]
        [string]$InstallPath = 'C:\WSL\DevUbuntu',

        [Parameter(HelpMessage = 'Enter the WSL distribution name.')]
        [string]$Name = 'DevUbuntu'
    )

    $tar = (Resolve-Path $Path).Path
    New-Item -ItemType Directory -Path $InstallPath -Force
    wsl --import $Name $InstallPath $tar --version 2
}
