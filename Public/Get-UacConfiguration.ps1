using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

function Get-UacConfiguration {
    <#
    .SYNOPSIS
        Gets UAC settings and their interpreted values.

    .EXAMPLE
        Get-UacConfiguration

        Returns the current registry settings and whether they match the function's hardened configuration.
    #>
    [CmdletBinding()]
    param()

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $config = Get-ItemProperty -Path $regPath

    $hardened = $config.ConsentPromptBehaviorAdmin -eq 1 -and
    $config.EnableLUA -eq 1 -and
    $config.PromptOnSecureDesktop -eq 1

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

