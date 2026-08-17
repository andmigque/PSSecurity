Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">New-LocalAdminUser</h2>
####
function New-LocalAdminUser {
    #### Create a local user account and add it to the Administrators group.
    ####
    #### Requires Administrator. Supports `-WhatIf`.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding(SupportsShouldProcess)]
    param(
        #### - `[PSCredential]`: __Credential__
        ####     - *Username and password for the new account.*
        ####     - *Windows caps a local account name at 20 characters.*
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        #### - `[string]`: __FullName__
        ####     - *Display name. Optional.*
        [Parameter(Mandatory = $false)]
        [string]$FullName,

        #### - `[string]`: __Description__
        ####     - *Account description. Optional.*
        [Parameter(Mandatory = $false)]
        [string]$Description,

        #### - `[switch]`: __PasswordNeverExpires__
        ####     - *Sets the account password to never expire.*
        [Parameter(Mandatory = $false)]
        [switch]$PasswordNeverExpires
    )

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When the session is not elevated.
    #### - When the account name is longer than 20 characters.
    #### - When the account already exists.
    Assert-Administrator

    #### Optional values are added only when supplied, so the splat never carries
    #### an empty string into a field that would then be set to blank.
    $userParams = @{
        Name     = $Credential.UserName
        Password = $Credential.Password
    }

    if ($FullName) { $userParams['FullName'] = $FullName }
    if ($Description) { $userParams['Description'] = $Description }
    if ($PasswordNeverExpires) { $userParams['PasswordNeverExpires'] = $true }

    #### One gate covers both calls. An account created but never added to
    #### Administrators is a worse outcome than no account at all.
    if (-not $PSCmdlet.ShouldProcess($Credential.UserName, 'Create local account and add to Administrators')) {
        return
    }

    [void](New-LocalUser @userParams)
    Add-LocalGroupMember -Group 'Administrators' -Member $Credential.UserName

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[PSCustomObject]`
    ####     - `[string]`: __Username__
    ####         - *Account name from `Credential.UserName`.*
    ####     - `[string]`: __FullName__
    ####         - *Display name, or empty when not supplied.*
    ####     - `[bool]`: __Created__
    ####         - *True. The function throws rather than reporting failure here.*
    ####     - `[bool]`: __IsAdministrator__
    ####         - *True. The account is added to Administrators before this returns.*
    ####     - `[bool]`: __PasswordNeverExpires__
    ####         - *Reflects the switch.*
    [PSCustomObject]@{
        Username             = $Credential.UserName
        FullName             = $FullName
        Created              = $true
        IsAdministrator      = $true
        PasswordNeverExpires = $PasswordNeverExpires.IsPresent
    }
}
####
#### ---
####

