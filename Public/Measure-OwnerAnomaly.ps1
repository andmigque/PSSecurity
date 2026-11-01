#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Measure-OwnerAnomaly {
    <#
    .SYNOPSIS
        Counts items whose owner differs from the expected identity.

    .DESCRIPTION
        Collects every piped ACL item and compares its Owner property with -Identity.
        Items whose owner does not match are anomalies. Returns one summary after the
        last item, with both counts and both collections.

    .PARAMETER AclItem
        An ACL item object with an Owner property, such as output from Get-AclItem.
        Accepts objects from the pipeline.

    .PARAMETER Identity
        The expected owner identity, as DOMAIN\User. Defaults to the current
        USERDOMAIN\USERNAME.

    .INPUTS
        System.Management.Automation.PSCustomObject. You can pipe ACL items to this
        function.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. One summary with AclItemCount,
        AnomalyCount, AclItems, and Anomalies.

    .EXAMPLE
        Get-AclItem -LiteralPath C:\Data | Measure-OwnerAnomaly

        Checks whether the current user owns C:\Data.

    .EXAMPLE
        Get-ChildItem -LiteralPath C:\Data -Recurse | ForEach-Object { Get-AclItem -LiteralPath $_.FullName } |
            Measure-OwnerAnomaly -Identity 'BUILTIN\Administrators'

        Counts the items under C:\Data that are not owned by Administrators.

    .EXAMPLE
        (Get-AclItem -LiteralPath C:\Data | Measure-OwnerAnomaly).Anomalies | Select-Object -Property FullName, Owner

        Lists the path and owner of each anomaly.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'ACL item object with an Owner property, such as output from Get-AclItem. Accepts pipeline input.')]
        [PSCustomObject]$AclItem,

        [Parameter(HelpMessage = 'Expected owner identity. Defaults to the current USERDOMAIN\USERNAME.')]
        [ValidateNotNullOrEmpty()]
        [string]$Identity = "$($env:USERDOMAIN)\$($env:USERNAME)"
    )
    begin {
        # A generic List returns void from Add. ArrayList returns the insert index,
        # which lands on the success stream ahead of the summary, one integer per input.
        $aclItems = [System.Collections.Generic.List[PSCustomObject]]::new()
        $anomalies = [System.Collections.Generic.List[PSCustomObject]]::new()
    }
    process {
        $aclItems.Add($AclItem)
        if ($AclItem.Owner -ne $Identity) {
            $anomalies.Add($AclItem)
        }
    }
    end {
        [PSCustomObject]@{
            AclItemCount = $aclItems.Count
            AnomalyCount = $anomalies.Count
            AclItems     = $aclItems
            Anomalies    = $anomalies
        }
    }
}
