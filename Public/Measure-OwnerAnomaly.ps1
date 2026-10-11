using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable
using namespace System.Security.AccessControl

Set-StrictMode -Version Latest

function Measure-OwnerAnomaly {
    <#
    .SYNOPSIS
        Counts items whose owner differs from the expected identity.

    .PARAMETER AclItem
        ACL item object with an Owner property, such as output from Get-AclItem. Accepts pipeline input.

    .PARAMETER Identity
        Expected owner identity. Defaults to the current USERDOMAIN\USERNAME.

    .EXAMPLE
        Get-AclItem -LiteralPath C:\Data | Measure-OwnerAnomaly

        Returns item and anomaly counts together with the corresponding collections.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'ACL item object with an Owner property, such as output from Get-AclItem. Accepts pipeline input.')]
        [PSCustomObject]$AclItem,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Expected owner identity. Defaults to the current USERDOMAIN\USERNAME.')]
        [string]$Identity = "$($env:USERDOMAIN)\$($env:USERNAME)"

    )
    begin {
        # A generic List returns void from Add. ArrayList returns the insert index,
        # which lands on the success stream ahead of the summary, one integer per input.
        $aclItems = [Collections.Generic.List[PSCustomObject]]::new()
        $anomalies = [Collections.Generic.List[PSCustomObject]]::new()
    }
    process {
        $aclItems.Add($AclItem)
        if ($AclItem.Owner -ne $Identity ) {
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

