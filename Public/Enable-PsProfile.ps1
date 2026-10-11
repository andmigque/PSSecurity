function Enable-PsProfile {
    [CmdletBinding()]
    param()

    if ($IsLinux) {
        $profileDirectory = Join-Path -Path "$PSScriptRoot" -ChildPath '.config' -AdditionalChildPath 'powershell'
        New-Item -Path $profileDirectory -ItemType Directory

        touch $PROFILE
        $parentDirectory = Split-Path -Path "$PSScriptRoot" -Parent

        $windowsProfile = Join-Path -Path $parentDirectory -ChildPath 'Config' -AdditionalChildPath 'WindowsProfile.ps1'

        Copy-Item $windowsProfile $PROFILE

        . $PROFILE
    }

    if ($IsWindows) {

        $profileDirectory = Split-Path -Path $PROFILE -Parent
        New-Item -Path $profileDirectory -ItemType Directory -Force

        $windowsProfile = Join-Path -Path $parentDirectory -ChildPath 'Config' -AdditionalChildPath 'WindowsProfile.ps1'

        Copy-Item $windowsProfile $PROFILE

        . $PROFILE
    }
}