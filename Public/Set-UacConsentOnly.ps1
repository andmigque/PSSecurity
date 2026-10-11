Set-StrictMode -Version Latest

function Set-UacConsentOnly {
    <#
    .SYNOPSIS
        Sets the administrator UAC consent policy to value 5.

    .EXAMPLE
        Set-UacConsentOnly -WhatIf

        Previews the registry change. Requires elevation; actual execution returns the before and after values.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Assert-Administrator

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

    $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    if (-not $PSCmdlet.ShouldProcess($regPath, 'Set ConsentPromptBehaviorAdmin to 5')) {
        return
    }

    Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 5

    $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    [PSCustomObject]@{
        Setting = 'ConsentPromptBehaviorAdmin'
        Before  = $before.ConsentPromptBehaviorAdmin
        After   = $after.ConsentPromptBehaviorAdmin
        Status  = 'Consent-only elevation (Windows default)'
    }
}

