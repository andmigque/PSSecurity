using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Test-Administrator</h2>
####
function Test-Administrator {
    [CmdletBinding()]
    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[bool]`
    ####     - *True when the principal holds the Administrator role.*
    [OutputType([bool])]
    param()
    #### > Test if a principal holds the Administrator role
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $hasAdminRole = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $hasAdminRole
}
####
#### ---
####

