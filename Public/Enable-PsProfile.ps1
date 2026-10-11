function Enable-PwshProfile {
    [CmdletBinding()]
    param()

    if ($IsLinux) {
        $profileDirectory = Join-Path -Path "$PSScriptRoot" -ChildPath '.config' -AdditionalChildPath 'powershell'
        New-Item -Path $profileDirectory -ItemType Directory

        New-Item -Path $PROFILE -ItemType File

        $parentDirectory = Split-Path -Path "$PSScriptRoot" -Parent

        $windowsProfile = Join-Path -Path $parentDirectory -ChildPath 'Config' -AdditionalChildPath 'PwshProfile.ps1'

        Copy-Item $windowsProfile $PROFILE

        . $PROFILE
    }

    if ($IsWindows) {

        $profileDirectory = Split-Path -Path $PROFILE -Parent
        New-Item -Path $profileDirectory -ItemType Directory -Force
        New-Item -Path $PROFILE -ItemType File -Force

        $windowsProfile = Join-Path -Path $parentDirectory -ChildPath 'Config' -AdditionalChildPath 'PwshProfile.ps1'

        Copy-Item $windowsProfile $PROFILE

        . $PROFILE
    }
}