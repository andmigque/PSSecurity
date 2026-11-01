#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Set-UacConsentOnly {
        <#
        .SYNOPSIS
            Sets the administrator UAC consent policy to value 5.

        .DESCRIPTION
            Sets ConsentPromptBehaviorAdmin under
            HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System to 5, the
            Windows default: administrators are prompted for consent, not credentials,
            for non-Windows binaries. Other UAC settings are unchanged. Use
            Set-UacRequirePassword to require credentials instead.

            Requires an elevated session, including for -WhatIf. Supports -WhatIf and
            -Confirm. Windows only.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object with the setting name,
            its value before and after, and the resulting policy. Nothing is returned for
            -WhatIf.

        .EXAMPLE
            Set-UacConsentOnly -WhatIf

            Previews the registry change.

        .EXAMPLE
            Set-UacConsentOnly

            Sets the consent-only policy and returns the before and after values.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param()

        Assert-Administrator

        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
        $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

        if ($PSCmdlet.ShouldProcess($regPath, 'Set ConsentPromptBehaviorAdmin to 5')) {
            Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 5
            $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

            [PSCustomObject]@{
                Setting = 'ConsentPromptBehaviorAdmin'
                Before  = $before.ConsentPromptBehaviorAdmin
                After   = $after.ConsentPromptBehaviorAdmin
                Status  = 'Consent-only elevation (Windows default)'
            }
        }
    }
}
