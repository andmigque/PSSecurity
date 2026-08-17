Set-StrictMode -Version Latest

if ($IsLinux) {
    #### <h2 style="color: #DCA657;">Start-SecurityWatch</h2>
    ####
    function Start-SecurityWatch {
        #### Tail the Linux audit log in real time.
        ####
        #### Blocks until interrupted. Interactive use only.
        ####
        #### Reads only. `ShouldProcess` is declared because the `Start` verb is treated
        #### as state changing, and `-WhatIf` is a reasonable way to ask what it watches
        #### without being trapped in a blocking tail.
        ####
        [CmdletBinding(SupportsShouldProcess)]
        param()

        if ($PSCmdlet.ShouldProcess('/var/log/audit/audit.log', 'Tail until interrupted')) {
            tail -f /var/log/audit/audit.log
        }
    }
    ####
    #### ---
    ####
}

