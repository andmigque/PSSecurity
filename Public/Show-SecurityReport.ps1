using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

if ($IsLinux) {
    #### <h2 style="color: #DCA657;">Show-SecurityReport</h2>
    ####
    function Show-SecurityReport {
        #### Print an aureport summary of audit events.
        ####
        #### Requires auditd to be installed and running.
        ####
        aureport --summary
    }
    ####
    #### ---
    ####
}

