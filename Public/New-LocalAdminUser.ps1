#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function New-LocalAdminUser {
        <#
        .SYNOPSIS
            Creates a local user and adds it to Administrators.

        .DESCRIPTION
            Creates a local account with New-LocalUser from the user name and password in
            the credential, then adds it to the local Administrators group. Requires an
            elevated session, including for -WhatIf. Supports -WhatIf and -Confirm.
            Windows only.

        .PARAMETER Credential
            Credential containing the new local account name and password. Accepts
            credentials from the pipeline; one account is created for each.

        .PARAMETER FullName
            Optional display name for the local account.

        .PARAMETER Description
            Optional description for the local account.

        .PARAMETER PasswordNeverExpires
            Prevents the new account password from expiring when specified.

        .INPUTS
            System.Management.Automation.PSCredential. You can pipe credentials to this
            function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One summary per created account
            with the user name, full name, and password expiry setting. Nothing is returned
            for -WhatIf.

        .EXAMPLE
            New-LocalAdminUser -Credential (Get-Credential) -WhatIf

            Previews account creation without creating the account.

        .EXAMPLE
            New-LocalAdminUser -Credential (Get-Credential) -FullName 'Break Glass' -PasswordNeverExpires

            Creates a local administrator whose password does not expire.

        .EXAMPLE
            Get-Credential | New-LocalAdminUser -Description 'Emergency access'

            Creates a local administrator from the piped credential.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'Credential containing the new local account name and password.')]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credential,

            [Parameter(HelpMessage = 'Optional display name for the local account.')]
            [string]$FullName,

            [Parameter(HelpMessage = 'Optional description for the local account.')]
            [string]$Description,

            [Parameter(HelpMessage = 'Prevents the new account password from expiring when specified.')]
            [switch]$PasswordNeverExpires
        )
        begin {
            Assert-Administrator
        }
        process {
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
    }
}
