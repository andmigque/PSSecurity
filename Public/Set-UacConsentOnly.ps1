using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Set-UacConsentOnly</h2>
####
function Set-UacConsentOnly {
    #### Set UAC back to consent only elevation.
    ####
    #### Sets `ConsentPromptBehaviorAdmin` to 5, the Windows default.
    #### This is the inverse of `Set-UacRequirePassword` and is not the hardened setting.
    #### Requires Administrator. Supports `-WhatIf`.
    ####
    [CmdletBinding(SupportsShouldProcess)]
    param()

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When the session is not elevated.
    Assert-Administrator

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

    $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    if (-not $PSCmdlet.ShouldProcess($regPath, 'Set ConsentPromptBehaviorAdmin to 5')) {
        return
    }

    Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 5

    $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[PSCustomObject]`
    ####     - *Same shape as `Set-UacRequirePassword`, with `After` set to 5.*
    [PSCustomObject]@{
        Setting = 'ConsentPromptBehaviorAdmin'
        Before  = $before.ConsentPromptBehaviorAdmin
        After   = $after.ConsentPromptBehaviorAdmin
        Status  = 'Consent-only elevation (Windows default)'
    }
}
####
#### ---
####

