Set-StrictMode -Version Latest

function Unprotect-Item {
    <#
    .SYNOPSIS
        Decrypts an item using Windows EFS.

    .PARAMETER Path
        Path to the item to decrypt. Accepts paths from the pipeline.

    .EXAMPLE
        Unprotect-Item -Path C:\Data\private.txt

        Decrypts the file using its Decrypt method. Requires access to the EFS decryption key.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true,
            HelpMessage = 'Path to the item to decrypt. Accepts paths from the pipeline.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        (Get-Item -Path $Path).Decrypt()
    }
}
