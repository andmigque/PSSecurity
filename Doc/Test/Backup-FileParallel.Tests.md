 <h1 style="color: #DCA657;">🎆 Backup-FileParallel.Tests</h1>

 > Unit tests for `Backup-FileParallel`.

 ---

 Each case builds a throwaway source tree under the temp directory and removes
 both trees afterward, so a failed run leaves nothing behind.

 ---

 <h2 style="color: #DCA657;">Backup-FileParallel</h2>

```powershell
Describe 'Backup-FileParallel'
```

 <b style="color: #D2A8FF;">Cases</b>

 - A missing source throws before any destination directory is created.
```powershell
It 'Throws when Path does not exist'
```

 ---

