#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Get-UacConfiguration {
        <#
        .SYNOPSIS
            Gets UAC settings and their interpreted values.

        .DESCRIPTION
            Reads ConsentPromptBehaviorAdmin, EnableLUA, and PromptOnSecureDesktop from
            HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System and describes
            each value. The configuration is hardened when UAC is enabled, administrators
            are prompted for credentials, and prompts appear on the secure desktop. Use
            Set-UacRequirePassword to apply that configuration. Windows only.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object with each registry
            value, its meaning, and whether the configuration is hardened.

        .EXAMPLE
            Get-UacConfiguration

            Returns the current registry settings and whether they match the hardened
            configuration.

        .EXAMPLE
            if (-not (Get-UacConfiguration).Hardened) { Set-UacRequirePassword }

            Applies the hardened configuration when the current one is not hardened.
        #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param()

        $config = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

        $hardened = $config.ConsentPromptBehaviorAdmin -eq 1 -and
            $config.EnableLUA -eq 1 -and
            $config.PromptOnSecureDesktop -eq 1

        $consentMeaning = switch ($config.ConsentPromptBehaviorAdmin) {
            0 { 'Elevate without prompting (INSECURE)' }
            1 { 'Prompt for credentials on secure desktop (HARDENED)' }
            2 { 'Prompt for consent on secure desktop' }
            3 { 'Prompt for credentials' }
            4 { 'Prompt for consent' }
            5 { 'Prompt for consent for non-Windows binaries (DEFAULT)' }
            default { 'Unknown' }
        }

        $luaMeaning = if ($config.EnableLUA -eq 1) {
            'UAC Enabled'
        }
        else {
            'UAC Disabled (INSECURE)'
        }

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
            ConsentPromptBehaviorAdminMeaning = $consentMeaning
            EnableLUA                         = $config.EnableLUA
            EnableLUAMeaning                  = $luaMeaning
            PromptOnSecureDesktop             = $config.PromptOnSecureDesktop
            PromptOnSecureDesktopMeaning      = $secureDesktopMeaning
            Hardened                          = $hardened
            HardenedStatus                    = $hardenedStatus
        }
    }
}
