Set-StrictMode -Version Latest

function New-LocalAdminUser {
    <#
    .SYNOPSIS
        Creates a local user and adds it to Administrators.

    .PARAMETER Credential
        Credential containing the new local account name and password.

    .PARAMETER FullName
        Optional display name for the local account.

    .PARAMETER Description
        Optional description for the local account.

    .PARAMETER PasswordNeverExpires
        Prevents the new account password from expiring when specified.

    .EXAMPLE
        New-LocalAdminUser -Credential (Get-Credential) -WhatIf

        Previews account creation. Requires an elevated session; an actual creation returns an account summary.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Credential containing the new local account name and password.')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Optional display name for the local account.')]
        [string]$FullName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Optional description for the local account.')]
        [string]$Description,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Prevents the new account password from expiring when specified.')]
        [switch]$PasswordNeverExpires
    )

    Assert-Administrator

    $userParams = @{
        Name     = $Credential.UserName
        Password = $Credential.Password
    }

    if ($FullName) { $userParams['FullName'] = $FullName }
    if ($Description) { $userParams['Description'] = $Description }
    if ($PasswordNeverExpires) { $userParams['PasswordNeverExpires'] = $true }

    if (-not $PSCmdlet.ShouldProcess($Credential.UserName, 'Create local account and add to Administrators')) {
        return
    }

    [void](New-LocalUser @userParams)
    Add-LocalGroupMember -Group 'Administrators' -Member $Credential.UserName

    [PSCustomObject]@{
        Username             = $Credential.UserName
        FullName             = $FullName
        Created              = $true
        IsAdministrator      = $true
        PasswordNeverExpires = $PasswordNeverExpires.IsPresent
    }
}

