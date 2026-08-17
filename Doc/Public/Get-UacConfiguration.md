 <h2 style="color: #DCA657;">Get-UacConfiguration</h2>

```powershell
function Get-UacConfiguration
```
 Reads only. No elevation required.

 Hardening needs all three together. A credential prompt that is not on the
 secure desktop can be driven by anything else running on that desktop.
 Hoisted out of the object literal. Inline, these two ran to 148 and 169
 characters, and the interesting half was off the right edge of the screen.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - `[int]`: __ConsentPromptBehaviorAdmin__
         - *Raw registry value, 0 through 5.*
     - `[string]`: __ConsentPromptBehaviorAdminMeaning__
         - *What that value means in practice.*
     - `[int]`: __EnableLUA__
         - *1 when UAC is on, 0 when it is off.*
     - `[string]`: __EnableLUAMeaning__
         - *`UAC Enabled`, or the insecure disabled message.*
     - `[int]`: __PromptOnSecureDesktop__
         - *1 when prompts use the secure desktop.*
     - `[string]`: __PromptOnSecureDesktopMeaning__
         - *What that value means in practice.*
     - `[bool]`: __Hardened__
         - *True only when all three settings match the baseline.*
     - `[string]`: __HardenedStatus__
         - *Status naming the settings involved, or the remediation to run.*

 ---

