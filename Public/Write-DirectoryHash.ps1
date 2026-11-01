#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Write-DirectoryHash {
    <#
    .SYNOPSIS
        Hashes the files in a directory tree using the module's hash settings.

    .DESCRIPTION
        Lists the files in the tree with Get-Tree on multiple threads and hashes each
        file with Get-FileHash. The file name patterns to include, the directory names to
        exclude, and the hash algorithm come from HashIndexInclude, HashIndexExclude,
        and HashIndexAlgorithm in Config/Setting.psd1.

        Each path is returned relative to the directory, with the home directory
        removed, so the output can be shared without revealing the user name.

    .PARAMETER Path
        The root directory to hash. Wildcards are accepted. Accepts paths from the
        pipeline.

    .INPUTS
        System.String. You can pipe directory paths to this function.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. One object per file with its
        relative Path and Hash.

    .EXAMPLE
        Write-DirectoryHash -Path .

        Hashes the files in the current directory tree.

    .EXAMPLE
        Write-DirectoryHash -Path ./Public | Sort-Object -Property Path | Export-Csv -LiteralPath ./PublicHash.csv

        Saves a sorted list of the hashes of the public functions.

    .EXAMPLE
        './Public', './Private' | Write-DirectoryHash

        Hashes the files in both directories.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Existing root directory to index using the module configured include, exclude, and hash settings.')]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    process {
        $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path

        # Include, Exclude, and the algorithm come from Config/Setting.psd1, loaded by PSSecurity.psm1.
        $treeParams = @{
            Path          = $resolvedPath
            File          = $true
            Include       = $script:HashIndexInclude
            Exclude       = $script:HashIndexExclude
            ThrottleLimit = Get-DefaultThrottleLimit
        }
        Get-Tree @treeParams |
            ForEach-Object {
                $hashObject = Get-FileHash -LiteralPath $_.FullName -Algorithm $script:HashIndexAlgorithm
                [PSCustomObject]@{
                    Path = [System.IO.Path]::GetRelativePath($resolvedPath, $hashObject.Path).Replace($HOME, '')
                    Hash = $hashObject.Hash
                }
            }
    }
}
