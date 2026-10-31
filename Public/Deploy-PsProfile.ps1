#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Deploy-PwshProfile {
    <#
        .SYNOPSIS
            Installs the PSSecurity pwsh profile for the current user and host.

        .DESCRIPTION
            Copies the module's profile script to $PROFILE (CurrentUserCurrentHost),
            creating the profile directory if it does not exist. On Linux the directory is
            ~/.config/powershell. On Windows it is the parent directory of $PROFILE. An
            existing profile is not replaced unless -Force is used. Supports -WhatIf and
            -Confirm.

            The profile is not loaded into the current session. Start a new session, or
            run . $PROFILE, to load it.

        .PARAMETER LiteralPath
            The profile script to install. The path is used exactly as typed. Defaults to
            Config/PwshProfile.ps1 in the module directory. Accepts a path from the
            pipeline.

        .PARAMETER Force
            Replaces an existing profile.

        .PARAMETER PassThru
            Returns the installed profile file.

        .INPUTS
            System.String. You can pipe a profile script path to this function. If you
            pipe more than one path, each replaces the last, so only the final one stays
            installed.

        .OUTPUTS
            System.IO.FileInfo. The installed profile, when -PassThru is used. Otherwise
            this function returns no output.

        .EXAMPLE
            Deploy-PwshProfile

            Installs the PSSecurity profile if the current user has no profile yet.

        .EXAMPLE
            Deploy-PwshProfile -Force -WhatIf

            Shows the profile that would be replaced, without changing it.

        .EXAMPLE
            Deploy-PwshProfile -LiteralPath ./MyProfile.ps1 -Force -PassThru

            Replaces the current profile with ./MyProfile.ps1 and returns the profile file.

        .EXAMPLE
            './MyProfile.ps1' | Deploy-PwshProfile -Force

            Replaces the current profile with the piped path.
        #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(ValueFromPipeline,
            HelpMessage = 'Enter the path of the profile script to install, treated literally. Accepts a path from the pipeline.')]
        [ValidateNotNullOrEmpty()]
        [string]$LiteralPath,

        [Parameter(HelpMessage = 'Replace an existing profile.')]
        [switch]$Force,

        [Parameter(HelpMessage = 'Return the installed profile file.')]
        [switch]$PassThru
    )
    begin {
        # Piped values are not bound until process, so only the default is resolved here.
        $moduleDirectory = Split-Path -Path $PSScriptRoot -Parent
        $defaultLiteralPath = Join-Path -Path $moduleDirectory -ChildPath 'Config' -AdditionalChildPath 'PwshProfile.ps1'
    }
    process {
        if (-not $PSBoundParameters.ContainsKey('LiteralPath')) {
            $LiteralPath = $defaultLiteralPath
        }

        if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
            throw "Deploy-PwshProfile can not find literal path: $LiteralPath"
        }

        if ($IsLinux) {
            $profileDirectory = Join-Path -Path $HOME -ChildPath '.config' -AdditionalChildPath 'powershell'
        }
        elseif ($IsWindows) {
            $profileDirectory = Split-Path -Path $PROFILE -Parent
        }
        else {
            throw 'Deploy-PwshProfile supports Linux and Windows only.'
        }

        if ((Test-Path -LiteralPath $PROFILE) -and -not $Force) {
            throw "A profile already exists at $PROFILE. Use -Force to replace it."
        }

        if ($PSCmdlet.ShouldProcess($PROFILE, "Install profile from $LiteralPath")) {

            if (-not (Test-Path -LiteralPath $profileDirectory)) {
                [void](New-Item -Path $profileDirectory -ItemType Directory)
            }

            Copy-Item -LiteralPath $LiteralPath -Destination $PROFILE -Force

            if ($PassThru) {
                Get-Item -LiteralPath $PROFILE
            }
        }
    }
}
