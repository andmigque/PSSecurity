 <h2 style="color: #DCA657;">Set-CronPermission</h2>

```powershell
function Set-CronPermission
```
 Restrict all standard cron directories to 700 via `sudo chmod`.

 A world readable cron directory lets any local account read what runs
 as root and when. A writable one lets them change it.

 Supports `-WhatIf`.


 <b style="color: #369FFF;">Returns</b>

 - `[string]`
     - *One line per directory that was changed.*
     - *A warning naming any directory that does not exist.*

 ---

