#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Set-AclItemOwner {
        <#
        .SYNOPSIS
            Changes an item's owner and returns its updated ACL details.

        .DESCRIPTION
            Sets the owner of each piped ACL item with Get-Acl and Set-Acl, then returns the
            item's details again from Get-AclItem. The access rules are unchanged.

            Requires an elevated session, including for -WhatIf. Supports -WhatIf and
            -Confirm. Windows only.

        .PARAMETER AclItem
            An ACL item from Get-AclItem, with FullName, Owner, and Name properties.
            Accepts objects from the pipeline.

        .PARAMETER Identity
            The new owner, as DOMAIN\User. Defaults to the current USERDOMAIN\USERNAME.

        .INPUTS
            System.Management.Automation.PSCustomObject. You can pipe ACL items from
            Get-AclItem to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. The Get-AclItem details of each
            changed item. Nothing is returned for -WhatIf.

        .EXAMPLE
            Get-AclItem -LiteralPath C:\Data | Set-AclItemOwner -Identity 'CONTOSO\Owner' -WhatIf

            Previews the ownership change.

        .EXAMPLE
            Get-AclItem -LiteralPath C:\Data | Set-AclItemOwner

            Makes the current user the owner of C:\Data.

        .EXAMPLE
            $anomalies = (Get-ChildItem -LiteralPath C:\Data | ForEach-Object { Get-AclItem -LiteralPath $_.FullName } |
                Measure-OwnerAnomaly -Identity 'BUILTIN\Administrators').Anomalies
            $anomalies | Set-AclItemOwner -Identity 'BUILTIN\Administrators'

            Gives Administrators ownership of every item in C:\Data that it does not own.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'ACL item from Get-AclItem, containing FullName, Owner, and Name. Accepts pipeline input.')]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$AclItem,

            [Parameter(HelpMessage = 'New owner account identity. Defaults to the current USERDOMAIN\USERNAME.')]
            [ValidateNotNullOrEmpty()]
            [string]$Identity
        )
        begin {
            Assert-Administrator

            if (-not $PSBoundParameters.ContainsKey('Identity')) {
                $Identity = "$($env:USERDOMAIN)\$($env:USERNAME)"
            }
            $newOwner = [System.Security.Principal.NTAccount]::new($Identity)
        }
        process {
            if (-not $AclItem.PSObject.Properties.Match('FullName').Count) {
                throw 'Usage: Get-Item -LiteralPath . | Get-AclItem | Set-AclItemOwner'
            }

            if ($PSCmdlet.ShouldProcess($AclItem.FullName, "Change owner from $($AclItem.Owner) to $newOwner on $($AclItem.Name)")) {
                $acl = Get-Acl -LiteralPath $AclItem.FullName
                $acl.SetOwner($newOwner)
                Set-Acl -LiteralPath $AclItem.FullName -AclObject $acl

                Get-AclItem -LiteralPath $AclItem.FullName
            }
        }
    }
}
