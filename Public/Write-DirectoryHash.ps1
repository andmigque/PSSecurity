using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

function Write-DirectoryHash {
    <#
    .SYNOPSIS
        Writes Markdown and JSON hash indexes for a directory.

    .PARAMETER Path
        Existing root directory to index using the module's configured include, exclude, and hash settings.

    .EXAMPLE
        Write-DirectoryHash -Path C:\Data

        Writes HashIndex.md and HashIndex.json in the directory and reports their paths. Existing index files are excluded and overwritten.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Existing root directory to index using the module''s configured include, exclude, and hash settings.')]
        [string]$Path
    )

    $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path

    # Remove the home directory prefix from the status output.
    $pathRedactionPrefix = (Resolve-Path '~').Path
    $markdownFile = Join-Path $resolvedPath 'HashIndex.md'
    $jsonFile = Join-Path $resolvedPath 'HashIndex.json'
    $rootDirectory = [System.IO.DirectoryInfo]::new($resolvedPath)

    # Skip excluded directories and existing index files.
    Get-IndexableFile -Directory $rootDirectory -Include $script:HashIndexInclude -Exclude $script:HashIndexExclude |
        Where-Object { $_.FullName -ne $jsonFile -and $_.FullName -ne $markdownFile } |
        ForEach-Object {
            $hashObject = Get-FileHash -Path $_.FullName -Algorithm $script:HashIndexAlgorithm
            [PSCustomObject]@{
                Path = [System.IO.Path]::GetRelativePath($resolvedPath, $hashObject.Path).Replace($pathRedactionPrefix, '')
                Hash = $hashObject.Hash
            }
        }

}

