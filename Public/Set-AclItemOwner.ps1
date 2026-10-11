Set-StrictMode -Version Latest

function Set-AclItemOwner {
    <#
    .SYNOPSIS
        Changes an item's owner and returns its updated ACL details.

    .PARAMETER AclItem
        ACL item from Get-AclItem, containing FullName, Owner, and Name. Accepts pipeline input.

    .PARAMETER Identity
        New owner account identity. Defaults to the current USERDOMAIN\USERNAME when omitted.

    .EXAMPLE
        Get-AclItem -LiteralPath C:\Data | Set-AclItemOwner -Identity 'CONTOSO\Owner' -WhatIf

        Previews the ownership change. Requires an elevated session.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline,
            HelpMessage = 'ACL item from Get-AclItem, containing FullName, Owner, and Name. Accepts pipeline input.')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$AclItem,

        [Parameter(HelpMessage = 'New owner account identity. Defaults to the current USERDOMAIN\USERNAME when omitted.')]
        [ValidateNotNullOrEmpty()]
        [string]$Identity
    )
    begin {
        Assert-Administrator
        if ([string]::IsNullOrWhiteSpace($Identity)) {
            $Identity = "$($env:USERDOMAIN)\$($env:USERNAME)"
        }
        $newOwner = [System.Security.Principal.NTAccount]::new($Identity)
    }
    process {
        if (-not $AclItem.PSObject.Properties.Match('FullName').Count) {
            throw 'Usage: Get-Item -LiteralPath . | Get-AclItem | Set-AclItemOwner'
        }
        $owner = $AclItem.Owner
        if ($PSCmdlet.ShouldProcess($AclItem.FullName, "Change owner from $owner to $newOwner on $($AclItem.Name)")) {
            $acl = Get-Acl -LiteralPath $AclItem.FullName
            $acl.SetOwner($newOwner)
            Set-Acl -LiteralPath $AclItem.FullName -AclObject $acl

            Get-AclItem -LiteralPath $AclItem.FullName
        }
    }
}

