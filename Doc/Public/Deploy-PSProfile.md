# Deploy-PSProfile

*Installs the PSSecurity pwsh profile for the current user and host.*

## DESCRIPTION

Copies the module's profile script to $PROFILE (CurrentUserCurrentHost),
creating the profile directory if it does not exist. On Linux the directory is
~/.config/powershell. On Windows it is the parent directory of $PROFILE. An
existing profile is not replaced unless -Force is used. Supports -WhatIf and
-Confirm.

The profile is not loaded into the current session. Start a new session, or
run . $PROFILE, to load it.

## PARAMETERS

### -LiteralPath

The profile script to install. The path is used exactly as typed. Defaults to
Config/PwshProfile.ps1 in the module directory. Accepts a path from the
pipeline.

### -Force

Replaces an existing profile.

### -PassThru

Returns the installed profile file.

## EXAMPLES

### Example 1

```powershell
Deploy-PwshProfile
```

Installs the PSSecurity profile if the current user has no profile yet.

### Example 2

```powershell
Deploy-PwshProfile -Force -WhatIf
```

Shows the profile that would be replaced, without changing it.

### Example 3

```powershell
Deploy-PwshProfile -LiteralPath ./MyProfile.ps1 -Force -PassThru
```

Replaces the current profile with ./MyProfile.ps1 and returns the profile file.

### Example 4

```powershell
'./MyProfile.ps1' | Deploy-PwshProfile -Force
```

Replaces the current profile with the piped path.

## INPUTS

System.String. You can pipe a profile script path to this function. If you
pipe more than one path, each replaces the last, so only the final one stays
installed.

## OUTPUTS

System.IO.FileInfo. The installed profile, when -PassThru is used. Otherwise
this function returns no output.

