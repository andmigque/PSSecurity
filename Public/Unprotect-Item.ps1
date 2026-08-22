Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Unprotect-Item</h2>
####
function Unprotect-Item {
    #### Decrypt an item protected by the Encrypting File System (EFS).
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[string]`: __Path__
        ####     - *Path to the item to decrypt. Accepts pipeline input.*
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        #### Decrypt the resolved file-system item with EFS.
        (Get-Item -Path $Path).Decrypt()
    }
}
####
#### ---
####
