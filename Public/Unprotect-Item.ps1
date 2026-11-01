#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Unprotect-Item {
        <#
        .SYNOPSIS
            Decrypts an item using Windows EFS.

        .DESCRIPTION
            Calls the Decrypt method of each item at the path. Requires access to the EFS
            key that encrypted the item. Use Protect-Item to encrypt. Supports -WhatIf and
            -Confirm. Windows only.

        .PARAMETER Path
            The path of the item to decrypt. Wildcards are accepted. Accepts paths from the
            pipeline.

        .INPUTS
            System.String. You can pipe item paths to this function.

        .OUTPUTS
            None. This function does not return output.

        .EXAMPLE
            Unprotect-Item -Path C:\Data\private.txt

            Decrypts the file.

        .EXAMPLE
            Unprotect-Item -Path C:\Data\*.txt -WhatIf

            Lists the text files in C:\Data that would be decrypted, without decrypting them.

        .EXAMPLE
            Get-ChildItem -Path C:\Data -File -Attributes Encrypted | Select-Object -ExpandProperty FullName | Unprotect-Item

            Decrypts each encrypted file in C:\Data.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'Path to the item to decrypt. Wildcards are accepted. Accepts paths from the pipeline.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path
        )
        process {
            foreach ($item in Get-Item -Path $Path) {
                if ($PSCmdlet.ShouldProcess($item.FullName, 'Decrypt with EFS')) {
                    $item.Decrypt()
                }
            }
        }
    }
}
