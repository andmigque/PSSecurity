#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Protect-Item {
        <#
        .SYNOPSIS
            Encrypts an item using Windows EFS.

        .DESCRIPTION
            Calls the Encrypt method of each item at the path. The file system must support
            EFS, such as NTFS. Use Unprotect-Item to decrypt. Supports -WhatIf and -Confirm.
            Windows only.

        .PARAMETER Path
            The path of the item to encrypt. Wildcards are accepted. Accepts paths from the
            pipeline.

        .INPUTS
            System.String. You can pipe item paths to this function.

        .OUTPUTS
            None. This function does not return output.

        .EXAMPLE
            Protect-Item -Path C:\Data\private.txt

            Encrypts the file.

        .EXAMPLE
            Protect-Item -Path C:\Data\*.txt -WhatIf

            Lists the text files in C:\Data that would be encrypted, without encrypting them.

        .EXAMPLE
            Get-ChildItem -Path C:\Data -File | Select-Object -ExpandProperty FullName | Protect-Item

            Encrypts each file in C:\Data.
        #>
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'Path to the item to encrypt. Wildcards are accepted. Accepts paths from the pipeline.')]
            [ValidateNotNullOrEmpty()]
            [string]$Path
        )
        process {
            foreach ($item in Get-Item -Path $Path) {
                if ($PSCmdlet.ShouldProcess($item.FullName, 'Encrypt with EFS')) {
                    $item.Encrypt()
                }
            }
        }
    }
}
