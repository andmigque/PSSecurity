using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Get-UacConfiguration</h2>
####
function Get-UacConfiguration {
    #### Reads only. No elevation required.
    ####
    [CmdletBinding()]
    param()

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $config = Get-ItemProperty -Path $regPath

    #### Hardening needs all three together. A credential prompt that is not on the
    #### secure desktop can be driven by anything else running on that desktop.
    $hardened = $config.ConsentPromptBehaviorAdmin -eq 1 -and
    $config.EnableLUA -eq 1 -and
    $config.PromptOnSecureDesktop -eq 1

    #### Hoisted out of the object literal. Inline, these two ran to 148 and 169
    #### characters, and the interesting half was off the right edge of the screen.
    $secureDesktopMeaning = if ($config.PromptOnSecureDesktop -eq 1) {
        'Secure Desktop Enabled'
    }
    else {
        'Secure Desktop Disabled'
    }

    $hardenedStatus = if ($hardened) {
        'HARDENED (UAC on, credential prompt, secure desktop)'
    }
    else {
        'NOT HARDENED - Run Set-UacRequirePassword'
    }

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[PSCustomObject]`
    ####     - `[int]`: __ConsentPromptBehaviorAdmin__
    ####         - *Raw registry value, 0 through 5.*
    ####     - `[string]`: __ConsentPromptBehaviorAdminMeaning__
    ####         - *What that value means in practice.*
    ####     - `[int]`: __EnableLUA__
    ####         - *1 when UAC is on, 0 when it is off.*
    ####     - `[string]`: __EnableLUAMeaning__
    ####         - *`UAC Enabled`, or the insecure disabled message.*
    ####     - `[int]`: __PromptOnSecureDesktop__
    ####         - *1 when prompts use the secure desktop.*
    ####     - `[string]`: __PromptOnSecureDesktopMeaning__
    ####         - *What that value means in practice.*
    ####     - `[bool]`: __Hardened__
    ####         - *True only when all three settings match the baseline.*
    ####     - `[string]`: __HardenedStatus__
    ####         - *Status naming the settings involved, or the remediation to run.*
    [PSCustomObject]@{
        ConsentPromptBehaviorAdmin        = $config.ConsentPromptBehaviorAdmin
        ConsentPromptBehaviorAdminMeaning = switch ($config.ConsentPromptBehaviorAdmin) {
            0 { 'Elevate without prompting (INSECURE)' }
            1 { 'Prompt for credentials on secure desktop (HARDENED)' }
            2 { 'Prompt for consent on secure desktop' }
            3 { 'Prompt for credentials' }
            4 { 'Prompt for consent' }
            5 { 'Prompt for consent for non-Windows binaries (DEFAULT)' }
            default { 'Unknown' }
        }
        EnableLUA                         = $config.EnableLUA
        EnableLUAMeaning                  = if ($config.EnableLUA -eq 1) { 'UAC Enabled' } else { 'UAC Disabled (INSECURE)' }
        PromptOnSecureDesktop             = $config.PromptOnSecureDesktop
        PromptOnSecureDesktopMeaning      = $secureDesktopMeaning
        Hardened                          = $hardened
        HardenedStatus                    = $hardenedStatus
    }
}
####
#### ---
####

