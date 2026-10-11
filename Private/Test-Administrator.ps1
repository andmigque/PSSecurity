using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

function Test-Administrator {
    [CmdletBinding()]
    [OutputType([bool])]
    param()
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $hasAdminRole = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $hasAdminRole
}

