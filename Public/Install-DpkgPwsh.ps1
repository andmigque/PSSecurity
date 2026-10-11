function Install-DpkgPwsh76 {
    [CmdletBinding()]
    param()

    wget https://github.com/PowerShell/PowerShell/releases/download/v7.6.6/powershell_7.6.6-1.deb_amd64.deb
    sudo dpkg -i powershell_7.6.6-1.deb_amd64.deb
    sudo apt-get install -f
    sudo apt-get install -y powershell
}