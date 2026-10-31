#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Test-Administrator {
        <#
        .SYNOPSIS
            Tests whether the current session is running as an administrator.

        .DESCRIPTION
            Returns true when the current Windows identity is in the built-in
            Administrators role, which requires an elevated session when UAC is on.
            Windows only.

        .INPUTS
            None. This function does not accept pipeline input.

        .OUTPUTS
            System.Boolean. True when the session is elevated, otherwise false.

        .EXAMPLE
            if (-not (Test-Administrator)) { Write-Warning -Message 'Run this from an elevated session.' }

            Warns when the session is not elevated.
        #>
        [CmdletBinding()]
        [OutputType([bool])]
        param()

        $principal = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}
