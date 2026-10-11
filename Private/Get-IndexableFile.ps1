Set-StrictMode -Version Latest

function Get-IndexableFile {
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory)][System.IO.DirectoryInfo]$Directory,

        [Parameter(Mandatory)][string[]]$Include,

        [Parameter(Mandatory)][string[]]$Exclude
    )

    foreach ($subDir in $Directory.EnumerateDirectories()) {
        if ($subDir.Name -in $Exclude) { continue }
        Get-IndexableFile -Directory $subDir -Include $Include -Exclude $Exclude
    }

    foreach ($file in $Directory.EnumerateFiles()) {
        foreach ($pattern in $Include) {
            if ($file.Name -like $pattern) {
                $file
                break
            }
        }
    }
}

