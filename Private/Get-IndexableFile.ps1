using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Get-IndexableFile</h2>
####
function Get-IndexableFile {
    #### Enumerate and return a list of included files.
    ####
    #### Exclusion happens by directory at enuermation time.
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        #### - `[DirectoryInfo]`: __Directory__
        ####     - *Directory to recursively enumerate.*
        [Parameter(Mandatory)][System.IO.DirectoryInfo]$Directory,

        #### - `[string[]]`: __Include__
        ####     - *Wildcard patterned file names.*
        [Parameter(Mandatory)][string[]]$Include,

        #### - `[string[]]`: __Exclude__
        ####     - *Directory basenames to exclude during enumeration.*
        [Parameter(Mandatory)][string[]]$Exclude
    )

    #### A directory whose `Name` is in `Exclude` is skipped before recursion.
    foreach ($subDir in $Directory.EnumerateDirectories()) {
        if ($subDir.Name -in $Exclude) { continue }
        Get-IndexableFile -Directory $subDir -Include $Include -Exclude $Exclude
    }

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - `[FileInfo]`
    ####     - *Return enumerated file whose `Name` matches a pattern in `Include`.*
    foreach ($file in $Directory.EnumerateFiles()) {
        foreach ($pattern in $Include) {
            if ($file.Name -like $pattern) {
                $file
                break
            }
        }
    }
}
####
#### ---
####

