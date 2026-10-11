
function New-WindowsUserProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^[^\\]+$')]
        [string] $UserName,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        $FullName,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        $Description,
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        $IsAdmin = $False
    )

    Set-StrictMode -Version Latest

    function Get-RegisteredProfilePath {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string] $Sid
        )

        $profileKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($Sid)"

        if (-not (Test-Path -LiteralPath $profileKey)) {
            return $null
        }

        $rawPath = (
            Get-ItemProperty -LiteralPath $profileKey -Name ProfileImagePath
        ).ProfileImagePath

        return [Environment]::ExpandEnvironmentVariables($rawPath)
    }

    New-LocalUser -FullName $FullName -Name $UserName -Description $Description

    if ($IsAdmin -eq $False) {
        Add-LocalGroupMember -Group 'Users' -Member $UserName
    }
    elseif ($IsAdmin -eq $True) {
        Add-LocalGroupMember -Group 'Administrators' -Member $UserName
    }

    try {
        $ntAccount = [System.Security.Principal.NTAccount]::new(
            $env:COMPUTERNAME,
            $UserName
        )

        $sidObject = $ntAccount.Translate(
            [System.Security.Principal.SecurityIdentifier]
        )
    }
    catch [System.Security.Principal.IdentityNotMappedException] {
        throw "$($env:COMPUTERNAME)\$($UserName) does not exist. Please create the account before creating the profile."
    
    }

    $sid = $sidObject.Value
    $canonicalAccountName = $sidObject.Translate(
        [System.Security.Principal.NTAccount]
    ).Value

    $existingPath = Get-RegisteredProfilePath -Sid $sid

    if ($null -ne $existingPath) {
        if (-not (Test-Path -LiteralPath $existingPath -PathType Container)) {
            throw "Windows registered profile $existingPath for $canonicalAccountName ($sid), but the directory is missing. Repair or remove the profile registration then retry."
        }

        [pscustomobject]@{
            Account     = $canonicalAccountName
            Sid         = $sid
            ProfilePath = $existingPath
            Created     = $false
        }

        return
    }

    if (-not ('WindowsProfile.NativeMethods' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

namespace WindowsProfile
{
    public static class NativeMethods
    {
        [DllImport(
            "userenv.dll",
            CharSet = CharSet.Unicode,
            ExactSpelling = true
        )]
        private static extern int CreateProfile(
            string pszUserSid,
            string pszUserName,
            StringBuilder pszProfilePath,
            uint cchProfilePath
        );

        public static string Create(string sid, string userName)
        {
            const int Capacity = 260;
            var profilePath = new StringBuilder(Capacity);

            int hresult = CreateProfile(
                sid,
                userName,
                profilePath,
                Capacity
            );

            if (hresult < 0)
            {
                Marshal.ThrowExceptionForHR(hresult);
            }

            return profilePath.ToString();
        }
    }
}
'@
    }

    $profilePath = [WindowsProfile.NativeMethods]::Create(
        $sid,
        $UserName
    )


    if (-not (Test-Path -LiteralPath $profilePath -PathType Container)) {
        throw "CreateProfile returned $($profilePath), but the profile directory was not created."
    }

    [pscustomobject]@{
        Account     = $canonicalAccountName
        Sid         = $sid
        ProfilePath = $profilePath
        Created     = $true
    }
}