
Set-StrictMode -Version Latest

function Write-DirectoryHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Existing root directory to index using the modules configured include, exclude, and hash settings.')]
        [string]$Path
    )

    $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path

    # Remove the home directory prefix from the status output.
    $pathRedactionPrefix = (Resolve-Path '~').Path
    $rootDirectory = [System.IO.DirectoryInfo]::new($resolvedPath)

    # Skip excluded directories and existing index files.
    Get-FileMultiThreaded -Directory $rootDirectory -Include $script:HashIndexInclude -Exclude $script:HashIndexExclude |
        ForEach-Object {
            $hashObject = Get-FileHash -Path $_.FullName -Algorithm $script:HashIndexAlgorithm
            [PSCustomObject]@{
                Path = [System.IO.Path]::GetRelativePath($resolvedPath, $hashObject.Path).Replace($pathRedactionPrefix, '')
                Hash = $hashObject.Hash
            }
        }

}

