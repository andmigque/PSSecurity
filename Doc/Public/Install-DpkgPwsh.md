# Install-DpkgPwsh

*Installs PowerShell 7.6.6 from the GitHub .deb package.*

## DESCRIPTION

Downloads the pinned PowerShell 7.6.6 amd64 .deb package to /tmp with wget,
installs it with dpkg, then lets apt install the dependencies the package
needs and finish the installation. The package is deleted afterward.

dpkg is expected to report unmet dependencies, which the apt steps that
follow repair, so only the download and apt steps stop the function.
Pipeline/harden-ubuntu-wsl-tar.yml runs the same steps.

Runs sudo, so it can prompt for a password. Supports -WhatIf and -Confirm.
Debian and Ubuntu only.

## EXAMPLES

### Example 1

```powershell
Install-DpkgPwsh
```

Installs PowerShell 7.6.6.

### Example 2

```powershell
Install-DpkgPwsh -WhatIf
```

Previews the installation without downloading the package.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.String. The output of wget, dpkg, and apt-get.

