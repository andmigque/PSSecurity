# Add-UnixFileMode

*Adds bits to the Unix mode of files or directories.*

## DESCRIPTION

Adds the -Mode bits to each item's existing UnixFileMode, the same as chmod
with +. Bits already set are kept, and items that already have every bit are
left unchanged. Takes items from Get-UnixFileMode, Get-ChildItem, or Get-Item,
or paths.

Changing an item you don't own requires root. Supports -WhatIf and -Confirm.
Linux only.

## PARAMETERS

### -LiteralPath

The path of the item to change, used exactly as typed. Accepts paths, and
items with a FullName property, from the pipeline.

### -Mode

The mode bits to add, such as StickyBit or GroupRead.

### -PassThru

Returns each item after the change.

## EXAMPLES

### Example 1

```powershell
Get-UnixFileMode -Path / -Mode OtherWrite -ItemType Directory | Add-UnixFileMode -Mode StickyBit -WhatIf
```

Lists the world-writable directories that would gain the sticky bit (CIS
1.1.21), with each mode before and after, without changing them.

### Example 2

```powershell
Add-UnixFileMode -LiteralPath /srv/share -Mode StickyBit -PassThru | Select-Object FullName, UnixFileMode
```

Adds the sticky bit to /srv/share and shows its new mode.

## INPUTS

System.String, System.IO.FileSystemInfo. You can pipe paths or file system
items to this function.

## OUTPUTS

System.IO.FileSystemInfo. With -PassThru, one object per item. Otherwise
nothing.

