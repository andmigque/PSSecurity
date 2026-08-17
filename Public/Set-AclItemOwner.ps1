Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Set-AclItemOwner</h2>
####
function Set-AclItemOwner {
    #### Change the owner of one item and return it as read back from disk.
    ####
    #### Requires Administrator. Supports `-WhatIf`.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding(SupportsShouldProcess)]
    param(
        #### - `[PSCustomObject]`: __AclItem__
        ####     - *An object from `Get-AclItem`. Accepts pipeline input.*
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$AclItem,

        #### - `[string]`: __Identity__
        ####     - *New owner as `DOMAIN\User`. Defaults to the current user.*
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Identity
    )
    begin {
        ####
        #### <b style="color: #C22514;">Throws</b>
        ####
        #### - When the session is not elevated.
        Assert-Administrator
        if ([string]::IsNullOrWhiteSpace($Identity)) {
            $Identity = "$($env:USERDOMAIN)\$($env:USERNAME)"
        }
        $newOwner = [System.Security.Principal.NTAccount]::new($Identity)
    }
    process {
        #### - When `AclItem` did not come from `Get-AclItem`.
        if (-not $AclItem.PSObject.Properties.Match('FullName').Count) {
            throw 'Usage: Get-Item -LiteralPath . | Get-AclItem | Set-AclItemOwner'
        }
        $owner = $AclItem.Owner
        if ($PSCmdlet.ShouldProcess($AclItem.FullName, "Change owner from $owner to $newOwner on $($AclItem.Name)")) {
            $acl = Get-Acl -LiteralPath $AclItem.FullName
            $acl.SetOwner($newOwner)
            Set-Acl -LiteralPath $AclItem.FullName -AclObject $acl

            ####
            #### <b style="color: #369FFF;">Returns</b>
            ####
            #### - `[PSCustomObject]`
            ####     - *A fresh `Get-AclItem` read, so the owner reflects disk and not intent.*
            ####     - *Nothing under `-WhatIf`.*
            Get-AclItem -LiteralPath $AclItem.FullName
        }
    }
}
####
#### ---
####

