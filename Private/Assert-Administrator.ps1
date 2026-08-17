using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Assert-Administrator</h2>
####
function Assert-Administrator {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    #### Throw when the Test-Administrator function returns false
    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    if (-not (Test-Administrator)) {
        throw 'Assert: Test-Administrator reports the Administrator role is missing.'
    }
}
####
#### ---
####

