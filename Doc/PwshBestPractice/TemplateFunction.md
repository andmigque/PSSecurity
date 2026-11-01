# Template Function

> The following is the standard template function for this repository:

```powershell
#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Invoke-ParallelJob {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER Path

    .INPUTS

    .OUTPUTS

    .EXAMPLE

    .EXAMPLE

    .EXAMPLE

    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'The path to process. Accepts string from pipeline.')]
        [string]$Path,
    )

    begin {

    }

    process {

    }
    
    end {

        try {

        }
        finally {

        }
    }
}


```