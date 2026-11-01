#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function New-WindowsUserProfile {
        <#
        .SYNOPSIS
            Creates a local user and its Windows profile directory.

        .DESCRIPTION
            Creates a local account with New-LocalUser, adds it to Users, or to
            Administrators with -IsAdmin, then creates the profile with the CreateProfile
            function in userenv.dll. Windows normally creates a profile at first logon;
            this creates it immediately.

            When Windows already has a profile registered for the account, the existing
            profile is returned instead. Throws when the profile is registered but its
            directory is missing.

            Requires an elevated session, including for -WhatIf. Supports -WhatIf and
            -Confirm. Windows only.

        .PARAMETER UserName
            The name of the new local account, without a domain or computer prefix.

        .PARAMETER FullName
            The display name of the new local account.

        .PARAMETER Description
            The description of the new local account.

        .PARAMETER IsAdmin
            Adds the account to Administrators instead of Users.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object with the account name,
            SID, profile path, and whether the profile was created. Nothing is returned for
            -WhatIf.

        .EXAMPLE
            New-WindowsUserProfile -UserName jdoe -FullName 'Jane Doe' -Description 'Analyst'

            Prompts for a password, creates jdoe as a standard user, and creates the
            profile directory.

        .EXAMPLE
            New-WindowsUserProfile -UserName svc-audit -FullName 'Audit Service' -Description 'Audit tasks' -IsAdmin

            Creates svc-audit as a local administrator with a profile directory.

        .EXAMPLE
            New-WindowsUserProfile -UserName jdoe -FullName 'Jane Doe' -Description 'Analyst' -WhatIf

            Previews the account and profile creation without making changes.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory, HelpMessage = 'Name of the new local account, without a domain or computer prefix.')]
            [ValidateNotNullOrEmpty()]
            [ValidatePattern('^[^\\]+$')]
            [string]$UserName,

            [Parameter(Mandatory, HelpMessage = 'Display name of the new local account.')]
            [ValidateNotNullOrEmpty()]
            [string]$FullName,

            [Parameter(Mandatory, HelpMessage = 'Description of the new local account.')]
            [ValidateNotNullOrEmpty()]
            [string]$Description,

            [Parameter(HelpMessage = 'Adds the account to Administrators instead of Users.')]
            [switch]$IsAdmin
        )
        begin {
            Assert-Administrator
        }
        process {
            $group = if ($IsAdmin) {
                'Administrators'
            }
            else {
                'Users'
            }

            if (-not $PSCmdlet.ShouldProcess($UserName, "Create local account, add to $group, and create profile")) {
                return
            }

            [void](New-LocalUser -Name $UserName -FullName $FullName -Description $Description)
            Add-LocalGroupMember -Group $group -Member $UserName

            try {
                $ntAccount = [System.Security.Principal.NTAccount]::new($env:COMPUTERNAME, $UserName)
                $sidObject = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
            }
            catch [System.Security.Principal.IdentityNotMappedException] {
                throw "$($env:COMPUTERNAME)\$($UserName) does not exist. Please create the account before creating the profile."
            }

            $sid = $sidObject.Value
            $canonicalAccountName = $sidObject.Translate([System.Security.Principal.NTAccount]).Value
            $profileKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"

            if (Test-Path -LiteralPath $profileKey) {
                $rawPath = (Get-ItemProperty -LiteralPath $profileKey -Name ProfileImagePath).ProfileImagePath
                $existingPath = [System.Environment]::ExpandEnvironmentVariables($rawPath)

                if (-not (Test-Path -LiteralPath $existingPath -PathType Container)) {
                    throw "Windows registered profile $existingPath for $canonicalAccountName ($sid), but the directory is missing. Repair or remove the profile registration then retry."
                }

                [PSCustomObject]@{
                    Account     = $canonicalAccountName
                    Sid         = $sid
                    ProfilePath = $existingPath
                    Created     = $false
                }
            }
            else {
                if (-not ('WindowsProfile.NativeMethods' -as [type])) {
                    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
using System.Text;

namespace WindowsProfile
{
    public static class NativeMethods
    {
        [DllImport("userenv.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
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

            int hresult = CreateProfile(sid, userName, profilePath, Capacity);

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

                $profilePath = [WindowsProfile.NativeMethods]::Create($sid, $UserName)

                if (-not (Test-Path -LiteralPath $profilePath -PathType Container)) {
                    throw "CreateProfile returned $profilePath, but the profile directory was not created."
                }

                [PSCustomObject]@{
                    Account     = $canonicalAccountName
                    Sid         = $sid
                    ProfilePath = $profilePath
                    Created     = $true
                }
            }
        }
    }
}
