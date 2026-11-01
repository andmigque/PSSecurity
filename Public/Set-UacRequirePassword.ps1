#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Set-UacRequirePassword {
        <#
        .SYNOPSIS
            Sets the administrator UAC credential policy to value 1.

        .DESCRIPTION
            Sets ConsentPromptBehaviorAdmin under
            HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System to 1:
            administrators must enter credentials on the secure desktop to elevate. This
            is the hardened value that Get-UacConfiguration checks for. Other UAC settings
            are unchanged.

            Requires an elevated session, including for -WhatIf. Supports -WhatIf and
            -Confirm. Windows only.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object with the setting name,
            its value before and after, and the resulting policy. Nothing is returned for
            -WhatIf.

        .EXAMPLE
            Set-UacRequirePassword -WhatIf

            Previews the registry change.

        .EXAMPLE
            if (-not (Get-UacConfiguration).Hardened) { Set-UacRequirePassword }

            Requires credentials for elevation when the current configuration is not
            hardened.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        [OutputType([PSCustomObject])]
        param()

        Assert-Administrator

        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
        $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

        if ($PSCmdlet.ShouldProcess($regPath, 'Set ConsentPromptBehaviorAdmin to 1')) {
            Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 1
            $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

            [PSCustomObject]@{
                Setting = 'ConsentPromptBehaviorAdmin'
                Before  = $before.ConsentPromptBehaviorAdmin
                After   = $after.ConsentPromptBehaviorAdmin
                Status  = 'Password required for elevation (hardened)'
            }
        }
    }
}
