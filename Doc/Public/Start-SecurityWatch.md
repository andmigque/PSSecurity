 <h2 style="color: #DCA657;">Start-SecurityWatch</h2>

```powershell
function Start-SecurityWatch
```
 Tail the Linux audit log in real time.

 Blocks until interrupted. Interactive use only.

 Reads only. `ShouldProcess` is declared because the `Start` verb is treated
 as state changing, and `-WhatIf` is a reasonable way to ask what it watches
 without being trapped in a blocking tail.


 ---

