#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Compare-MegaHash {
    <#
    .SYNOPSIS
        Compares a directory tree with the joined hash saved by Join-MegaHash.

    .DESCRIPTION
        Renames PSSecurity.hash in the module root to PSSecurity.hash.orig, replacing
        an existing .orig file, then runs Join-MegaHash to write a new PSSecurity.hash
        and compares the two files. Returns nothing when the tree is unchanged.

        Run Join-MegaHash with the same -Path first.

    .PARAMETER Path
        The root directory to hash. Use the same path that was given to Join-MegaHash.

    .INPUTS
        None. You can't pipe objects to this function.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. The Compare-Object differences
        between the saved and the new joined hash. Nothing when they match.

    .EXAMPLE
        Join-MegaHash -Path .
        Compare-MegaHash -Path .

        Saves the joined hash of the current tree, then checks it again. Returns
        nothing because nothing changed in between.

    .EXAMPLE
        if (Compare-MegaHash -Path .) { throw 'The module files have changed.' }

        Stops when the tree no longer matches the saved hash.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, HelpMessage = 'Enter the root directory to hash, as given to Join-MegaHash.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    $hashPath = Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.hash'
    $originalPath = "$hashPath.orig"

    if (-not (Test-Path -LiteralPath $hashPath)) {
        throw "Compare-MegaHash can not find $hashPath. Run Join-MegaHash first."
    }

    Move-Item -LiteralPath $hashPath -Destination $originalPath -Force
    $newPath = Join-MegaHash -Path $Path

    $compareParams = @{
        ReferenceObject  = Get-Content -LiteralPath $originalPath
        DifferenceObject = Get-Content -LiteralPath $newPath
    }
    Compare-Object @compareParams
}
