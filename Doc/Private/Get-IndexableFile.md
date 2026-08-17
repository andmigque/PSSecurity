 <h2 style="color: #DCA657;">Get-IndexableFile</h2>

```powershell
function Get-IndexableFile
```
 Enumerate and return a list of included files.

 Exclusion happens by directory at enuermation time.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[DirectoryInfo]`: __Directory__
     - *Directory to recursively enumerate.*
 - `[string[]]`: __Include__
     - *Wildcard patterned file names.*
 - `[string[]]`: __Exclude__
     - *Directory basenames to exclude during enumeration.*
 A directory whose `Name` is in `Exclude` is skipped before recursion.

 <b style="color: #369FFF;">Returns</b>

 - `[FileInfo]`
     - *Return enumerated file whose `Name` matches a pattern in `Include`.*

 ---

