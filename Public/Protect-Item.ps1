Set-StrictMode -Version Latest

function Protect-Item {
    <#
    .SYNOPSIS
        Encrypts an item using Windows EFS.

    .PARAMETER Path
        Path to the item to encrypt. Accepts paths from the pipeline.

    .EXAMPLE
        Protect-Item -Path C:\Data\private.txt

        Encrypts the file using its Encrypt method. Requires an EFS-capable filesystem.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true,
            HelpMessage = 'Path to the item to encrypt. Accepts paths from the pipeline.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        (Get-Item -Path $Path).Encrypt()
    }
}
