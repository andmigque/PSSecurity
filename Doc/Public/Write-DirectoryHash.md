 <h2 style="color: #DCA657;">Write-DirectoryHash</h2>

```powershell
function Write-DirectoryHash
```
 Creates Markdown and JSON hash indexes for files under a directory.

 The function writes `HashIndex.md` and `HashIndex.json` under `Path`.
 Paths in both indexes are relative to that directory.

 ```powershell
 Write-DirectoryHash -Path $PSScriptRoot
 ```

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Path__
     - *Directory to index recursively.*

 <b style="color: #C22514;">Throws</b>

 - When `Path` does not resolve.

 <b style="color: #369FFF;">Returns</b>

 - `[string]`
     - *One line per index file written, with the home prefix redacted.*

 ---

