using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Write-DirectoryHash</h2>
####
function Write-DirectoryHash {
    #### Creates Markdown and JSON hash indexes for files under a directory.
    ####
    #### The function writes `HashIndex.md` and `HashIndex.json` under `Path`.
    #### Paths in both indexes are relative to that directory.
    ####
    #### ```powershell
    #### Write-DirectoryHash -Path $PSScriptRoot
    #### ```
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param (
        #### - `[string]`: __Path__
        ####     - *Directory to index recursively.*
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When `Path` does not resolve.
    $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path

    # Remove the home directory prefix from the status output.
    $pathRedactionPrefix = (Resolve-Path '~').Path
    $markdownFile = Join-Path $resolvedPath 'HashIndex.md'
    $jsonFile = Join-Path $resolvedPath 'HashIndex.json'
    $rootDirectory = [System.IO.DirectoryInfo]::new($resolvedPath)

    # Skip excluded directories and existing index files.
    $records = Get-IndexableFile -Directory $rootDirectory -Include $script:HashIndexInclude -Exclude $script:HashIndexExclude |
        Where-Object { $_.FullName -ne $jsonFile -and $_.FullName -ne $markdownFile } |
        ForEach-Object {
            $hashObject = Get-FileHash -Path $_.FullName -Algorithm $script:HashIndexAlgorithm
            [PSCustomObject]@{
                File = $_.Name
                Hash = $hashObject.Hash
                Path = [System.IO.Path]::GetRelativePath($resolvedPath, $hashObject.Path)
            }
        }

    $header = @"
# Hash Index

**TickStamp** : $((Get-Date).Ticks)
**Algorithm** : $($script:HashIndexAlgorithm)
**Include** : $($script:HashIndexInclude -join ' ')
**PathBase** : repository relative

"@

    $rows = foreach ($record in $records) {
        "- $($record.Path),$($record.File),$($record.Hash)"
    }

    ($header + ($rows -join "`n") + "`n") | Out-File -FilePath $markdownFile -Encoding utf8
    @($records) | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonFile -Encoding utf8

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[string]`
    ####     - *One line per index file written, with the home prefix redacted.*
    Write-Output "Wrote $($markdownFile.Replace($pathRedactionPrefix, ''))"
    Write-Output "Wrote $($jsonFile.Replace($pathRedactionPrefix, ''))"
}
####
#### ---
####

