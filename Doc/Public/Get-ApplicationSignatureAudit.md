 <h2 style="color: #DCA657;">Get-ApplicationSignatureAudit</h2>

```powershell
function Get-ApplicationSignatureAudit
```
 Audit Authenticode signatures for every command visible on PATH.

 WindowsApps stubs are excluded. They are reparse points to packaged
 applications and report nothing useful about the binary behind them.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[int]`: __ThrottleLimit__
     - *Parallel throttle limit. Range 1 to 64. Defaults to 4.*

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject[]]`
     - `[string]`: __Name__
         - *Command name.*
     - `[string]`: __Path__
         - *Absolute path to the executable.*
     - `[string]`: __Status__
         - *Signature status, for example `Valid`, `NotSigned`, or `Error`.*
     - `[string]`: __StatusMessage__
         - *Free form status text from the signature check.*
     - `[string]`: __SignerCertificate__
         - *Subject of the signer certificate, or `Unsigned`.*
     - `[string]`: __TimeStamper__
         - *Subject of the timestamp certificate, or `None`.*
     - `[bool]`: __IsOSBinary__
         - *True for a Microsoft signed operating system binary.*
     - `[string]`: __SignatureType__
         - *Signature type, for example `Authenticode`, `Catalog`, or `Unknown`.*
 A file that cannot be read still gets a row, with `Status` set to
 `Error` and the exception in `StatusMessage`. An audit that silently
 drops unreadable binaries reports a cleaner PATH than the one you have.

 ---

