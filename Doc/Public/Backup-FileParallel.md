 <h2 style="color: #DCA657;">Backup-FileParallel</h2>

```powershell
function Backup-FileParallel
```
 Mirror a directory tree to a destination as gzip files.

 The walk is recursive and the destination mirrors the source tree.
 Compression runs in parallel across files at `CompressionLevel.SmallestSize`.
 Per file failures are collected and written to `CompressionErrors.json`.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Path__
     - *Existing source directory. Walked recursively.*
 - `[string]`: __OutPath__
     - *Destination root. Created when missing. Mirrors the source tree.*
 - `[int]`: __Throttle__
     - *Throttle for `ForEach-Object -Parallel`. Defaults to 4.*

 <b style="color: #C22514;">Throws</b>

 - When `Path` does not exist.
 - When `Path` and `OutPath` are the same directory.
 Both roots resolve to absolute paths before the parallel block starts.
 A relative path binds to each worker's own working directory, which is
 not guaranteed to match the caller's.
 Workers share one thread safe collection. `ConcurrentDictionary` holds the
 per file errors.

 <b style="color: #369FFF;">Returns</b>

 - *Nothing on the success stream.*
 - *Writes one `.gz` per source file, mirroring the tree under `OutPath`.*
 - *Writes `CompressionErrors.json` under `OutPath` when any file failed,*
   *and raises a warning naming that file.*

 ---

