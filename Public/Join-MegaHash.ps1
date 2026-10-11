function Join-MegaHash {
    [CmdletBinding()]
    param()
    $hashes = Write-DirectoryHash
    $megaHash = $hashes.Hash -join ''
    $parentPath = Split-Path "$PSScriptRoot" -Parent
    $path = Join-Path -Path $parentPath -ChildPath 'PSSecurity.hash'
    $megaHash | Out-File $path
    return $path
}

function Compare-MegaHash {
    [CmdletBinding()]
    param()
    $parentPath = Split-Path "$PSScriptRoot" -Parent
    $path = Join-Path -Path $parentPath -ChildPath 'PSSecurity.hash'

    Move-Item -Path $path -Destination "$($path).orig"

    $megaHash = Join-MegaHash

    Compare-Object -ReferenceObject "$($path).orig" -DifferenceObject $megaHash
}