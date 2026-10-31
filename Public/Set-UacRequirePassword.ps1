using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

function Set-UacRequirePassword {
    <#
    .SYNOPSIS
        Sets the administrator UAC credential policy to value 1.

    .EXAMPLE
        Set-UacRequirePassword -WhatIf

        Previews the registry change.
        Requires elevation; actual execution returns the before and after values. 
        Other UAC settings are unchanged.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Assert-Administrator

    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    if (-not $PSCmdlet.ShouldProcess($regPath, 'Set ConsentPromptBehaviorAdmin to 1')) {
        return
    }

    Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 1
    $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

    [PSCustomObject]@{
        Setting = 'ConsentPromptBehaviorAdmin'
        Before  = $before.ConsentPromptBehaviorAdmin
        After   = $after.ConsentPromptBehaviorAdmin
        Status  = 'Password required for elevation (hardened)'
    }
}

