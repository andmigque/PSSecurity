using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Set-UacRequirePassword</h2>
####
function Set-UacRequirePassword {
    #### Set UAC to prompt for credentials on the secure desktop.
    ####
    #### Sets `ConsentPromptBehaviorAdmin` to 1, so elevation requires credentials.
    #### Requires Administrator. Supports `-WhatIf`.
    ####
    [CmdletBinding(SupportsShouldProcess)]
    param()

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When the session is not elevated.
    Assert-Administrator

    #### The value is read before and after the write, so the caller sees the
    #### transition rather than the intent.
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    if (-not $PSCmdlet.ShouldProcess($regPath, 'Set ConsentPromptBehaviorAdmin to 1')) {
        return
    }

    Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 1
    $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[PSCustomObject]`
    ####     - `[string]`: __Setting__
    ####         - *`ConsentPromptBehaviorAdmin`.*
    ####     - `[int]`: __Before__
    ####         - *Registry value before the write.*
    ####     - `[int]`: __After__
    ####         - *Registry value after the write, read back from the registry.*
    ####     - `[string]`: __Status__
    ####         - *What the new value means.*
    [PSCustomObject]@{
        Setting = 'ConsentPromptBehaviorAdmin'
        Before  = $before.ConsentPromptBehaviorAdmin
        After   = $after.ConsentPromptBehaviorAdmin
        Status  = 'Password required for elevation (hardened)'
    }
}
####
#### ---
####

