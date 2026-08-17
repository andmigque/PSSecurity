using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable
using namespace System.Security.AccessControl

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Measure-OwnerAnomaly</h2>
####
function Measure-OwnerAnomaly {
    #### Summarize a pipeline of `Get-AclItem` objects by owner.
    ####
    #### An item owned by anyone other than `Identity` is an anomaly.
    #### Scope belongs to the caller, so point the pipeline at what you want measured.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[PSCustomObject]`: __AclItem__
        ####     - *An object from `Get-AclItem`. Accepts pipeline input.*
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$AclItem,

        #### - `[string]`: __Identity__
        ####     - *Expected owner as `DOMAIN\User`. Defaults to the current user.*
        ####     - *Compared without regard to case.*
        [Parameter(Mandatory = $false)]
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
        ####
        #### <b style="color: #369FFF;">Returns</b>
        ####
        #### - `[PSCustomObject]`
        ####     - *One summary for the whole pipeline, emitted once.*
        ####     - `[int]`: __AclItemCount__
        ####         - *Items that came down the pipeline.*
        ####     - `[int]`: __AnomalyCount__
        ####         - *Items owned by someone other than `Identity`.*
        ####     - `[PSCustomObject[]]`: __AclItems__
        ####         - *Every input, in pipeline order.*
        ####     - `[PSCustomObject[]]`: __Anomalies__
        ####         - *The offending items. Group by `Owner` to see who holds them.*
        [PSCustomObject]@{
            AclItemCount = $aclItems.Count
            AnomalyCount = $anomalies.Count
            AclItems     = $aclItems
            Anomalies    = $anomalies
        }
    }
}
####
#### ---
####

