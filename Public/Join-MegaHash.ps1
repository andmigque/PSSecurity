#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Join-MegaHash {
    <#
    .SYNOPSIS
        Joins the hashes of a directory tree into one file.

    .DESCRIPTION
        Hashes the directory tree with Write-DirectoryHash, joins every hash into one
        string, and writes it to PSSecurity.hash in the module root. An existing
        PSSecurity.hash is overwritten. Use Compare-MegaHash to check whether the tree
        has changed since.

        The hashes are joined in the order Write-DirectoryHash returns them.

    .PARAMETER Path
        The root directory to hash.

    .INPUTS
        None. You can't pipe objects to this function.

    .OUTPUTS
        System.String. The path of PSSecurity.hash.

    .EXAMPLE
        Join-MegaHash -Path .

        Writes the joined hash of the current directory tree to PSSecurity.hash.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, HelpMessage = 'Enter the root directory to hash.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $megaHash = (Write-DirectoryHash -Path $Path).Hash -join ''
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    $hashPath = Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.hash'

    $megaHash | Out-File -LiteralPath $hashPath
    $hashPath
}
