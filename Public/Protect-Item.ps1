Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Protect-Item</h2>
####
function Protect-Item {
    #### Encrypt an item by using the Encrypting File System (EFS).
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[string]`: __Path__
        ####     - *Path to the item to encrypt. Accepts pipeline input.*
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        #### Encrypt the resolved file-system item with EFS.
        (Get-Item -Path $Path).Encrypt()
    }
}
####
#### ---
####
