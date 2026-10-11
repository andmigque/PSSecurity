using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

function Assert-Administrator {
    [CmdletBinding()]
    [OutputType([void])]
    param()
    if (-not (Test-Administrator)) {
        throw 'Assert: Test-Administrator reports the Administrator role is missing.'
    }
}

