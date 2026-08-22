using namespace System
using namespace System.Collections.Generic

Set-StrictMode -Version Latest

function Add-Behavior {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$CustomObject
    )

    begin {
        $accumulator = [List[PSCustomObject]]::new()
    }

    process {
        try {
            $accumulator.Add($CustomObject)
        }
        catch {
            Write-Error "An error occurred accumulating the input object $($_.ErrorDetails)"
            throw
        }
    }

    end {
        $accumulator
    }
}