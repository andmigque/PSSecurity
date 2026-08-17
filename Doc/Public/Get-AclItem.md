 <h2 style="color: #DCA657;">Get-AclItem</h2>

```powershell
function Get-AclItem
```
 Read one file or directory and project its access control list.

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __LiteralPath__
     - *File or directory to read. Accepts pipeline input.*

 <b style="color: #C22514;">Throws</b>

 - When `LiteralPath` does not exist.

 <b style="color: #369FFF;">Returns</b>

 - `[PSCustomObject]`
     - `[string]`: __FullName__
         - *Absolute path of the item.*
     - `[string]`: __Name__
         - *Leaf name of the item.*
     - `[string]`: __Path__
         - *Provider qualified path from the access control list.*
     - `[string]`: __ItemType__
         - *`FileInfo` or `DirectoryInfo`.*
     - `[string]`: __Owner__
         - *Principal that owns the item.*
     - `[string]`: __Group__
         - *Primary group of the item.*
     - `[PSCustomObject[]]`: __Access__
         - *One entry per access control entry. Fields below.*
         - `[FileSystemRights]`: __FileSystemRights__
             - *Rights granted or denied. Test with `-band`, never a string match.*
         - `[AccessControlType]`: __AccessControlType__
             - *`Allow` or `Deny`.*
         - `[IdentityReference]`: __IdentityReference__
             - *Principal the entry applies to. Kept as an object so it translates to a SID.*
         - `[bool]`: __IsInherited__
             - *True when the entry comes from a parent container.*
         - `[InheritanceFlags]`: __InheritanceFlags__
             - *How the entry propagates to children.*
         - `[PropagationFlags]`: __PropagationFlags__
             - *Propagation modifiers for the entry.*
     - `[datetime]`: __CreationTime__ / __LastAccessTime__ / __LastWriteTime__
         - *File system timestamps.*
     - `[string]`: __Mode__
         - *Short attribute rendering, for example `-a---`.*
     - `[FileAttributes]`: __Attributes__
         - *Attribute flags. Carries `ReadOnly` and `Hidden`.*
     - `[string]`: __Security__
         - *The whole descriptor as SDDL.*
     - `[bool]`: __AreAccessRulesCanonical__
         - *False means deny entries may be evaluated after allow entries.*
     - `[bool]`: __AreAuditRulesCanonical__
         - *Same ordering test for the audit list.*
     - `[bool]`: __AreAccessRulesProtected__
         - *True means inheritance is broken on this item.*
     - `[bool]`: __AreAuditRulesProtected__
         - *True means audit inheritance is broken on this item.*

 ---

