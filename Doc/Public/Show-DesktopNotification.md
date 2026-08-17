 <h2 style="color: #DCA657;">Show-DesktopNotification</h2>

```powershell
function Show-DesktopNotification
```
 Raise a desktop toast through BurntToast.

 ```powershell
 Show-DesktopNotification -Title 'Search-PatternInFile complete' -Message "142 matches written to $jsonPath"
 ```

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Title__
     - *Toast heading. Keep it to the command and its outcome.*
 - `[string]`: __Message__
     - *Toast body. Put the full output path here, since that is what the reader came back for.*
 - `[string]`: __UniqueIdentifier__
     - *Toasts sharing an identifier replace each other instead of stacking.*
     - *Pass one when a command can run repeatedly, so the newest result is the one on screen.*
 - `[string]`: __LaunchPath__
     - *File or folder the toast body opens when clicked.*
     - *Without it the click activates the registered app, which is PowerShell.*

 <b style="color: #C22514;">Throws</b>

 - When the host is not Windows.
 - When BurntToast is not installed.
 Splatted because UniqueIdentifier is optional, and passing it as an empty
 string would create a toast that every other empty-identifier toast replaces.

 <b style="color: #369FFF;">Returns</b>

 - *Nothing.*

 ---

