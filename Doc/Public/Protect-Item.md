# Protect-Item

*Encrypts an item using Windows EFS.*

## DESCRIPTION

Calls the Encrypt method of each item at the path. The file system must support
EFS, such as NTFS. Use Unprotect-Item to decrypt. Supports -WhatIf and -Confirm.
Windows only.

## PARAMETERS

### -Path

The path of the item to encrypt. Wildcards are accepted. Accepts paths from the
pipeline.

## EXAMPLES

### Example 1

```powershell
Protect-Item -Path C:\Data\private.txt
```

Encrypts the file.

### Example 2

```powershell
Protect-Item -Path C:\Data\*.txt -WhatIf
```

Lists the text files in C:\Data that would be encrypted, without encrypting them.

### Example 3

```powershell
Get-ChildItem -Path C:\Data -File | Select-Object -ExpandProperty FullName | Protect-Item
```

Encrypts each file in C:\Data.

## INPUTS

System.String. You can pipe item paths to this function.

## OUTPUTS

None. This function does not return output.

