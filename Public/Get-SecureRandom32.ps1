using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Get-SecureRandom32</h2>
####
function Get-SecureRandom32 {
    #### Generate a cryptographically secure random alphanumeric string.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[int]`: __Length__
        ####     - *Length of the output string. Range 1 to 512. Defaults to 32.*
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 512)]
        [int]$Length = 32
    )

    $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[string]`
    ####     - *Random alphanumeric string drawn from `[A-Za-z0-9]`.*
    ####
    #### `RandomNumberGenerator.GetInt32` draws from the platform CSPRNG and is
    #### free of the modulo bias a `% length` on a raw byte would introduce.
    return -join (1..$Length | ForEach-Object { $alphabet[[RandomNumberGenerator]::GetInt32(0, $alphabet.Length)] })
}
####
#### ---
####

