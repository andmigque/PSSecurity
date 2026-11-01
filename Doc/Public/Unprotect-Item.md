# Unprotect-Item

*Decrypts an item using Windows EFS.*

## DESCRIPTION

Calls the Decrypt method of each item at the path. Requires access to the EFS
key that encrypted the item. Use Protect-Item to encrypt. Supports -WhatIf and
-Confirm. Windows only.

## PARAMETERS

### -Path

The path of the item to decrypt. Wildcards are accepted. Accepts paths from the
pipeline.

## EXAMPLES

### Example 1

```powershell
Unprotect-Item -Path C:\Data\private.txt
```

Decrypts the file.

### Example 2

```powershell
Unprotect-Item -Path C:\Data\*.txt -WhatIf
```

Lists the text files in C:\Data that would be decrypted, without decrypting them.

### Example 3

```powershell
Get-ChildItem -Path C:\Data -File -Attributes Encrypted | Select-Object -ExpandProperty FullName | Unprotect-Item
```

Decrypts each encrypted file in C:\Data.

## INPUTS

System.String. You can pipe item paths to this function.

## OUTPUTS

None. This function does not return output.

