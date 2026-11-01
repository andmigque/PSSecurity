# Deploy-LinuxConfiguration

*Copies the PSSecurity Linux hardening files from Config/Linux into place.*

## DESCRIPTION

Config/Linux mirrors the root of the file system, so each file is copied to the
same path under /. For example, Config/Linux/etc/sysctl.d/99-pssecurity-hardening.conf
is copied to /etc/sysctl.d/99-pssecurity-hardening.conf. Missing directories are
created. Every copied file gets mode 0644, whatever the mode of its source. A file
whose destination already has the same content and mode 0644 is skipped, so a
run also repairs the mode of files deployed earlier.

The files are drop-ins in standard locations: kernel parameters in sysctl.d,
the kernel module blacklist in modprobe.d, and the core dump policy in
security/limits.d and systemd/coredump.conf.d. Edit the files in Config/Linux to
change the policy.

After a sysctl.d file is copied, runs sysctl --system to apply it without a
reboot. Keys the running kernel does not support, common in containers and WSL,
are reported as a warning; the file is still deployed and applies at boot on
kernels that support them.

Requires root. Supports -WhatIf and -Confirm. Linux only.

## PARAMETERS

### -Name

File names to deploy, such as 99-pssecurity-hardening.conf. Wildcards are
accepted. Defaults to every file in Config/Linux.

### -PassThru

Returns each file that was copied.

## EXAMPLES

### Example 1

```powershell
Deploy-LinuxConfiguration -WhatIf
```

Lists the files that would be copied and where.

### Example 2

```powershell
Invoke-Sudo { Import-Module ./PSSecurity.psd1; Deploy-LinuxConfiguration -PassThru }
```

Deploys every file as root and lists the files that were copied.

### Example 3

```powershell
Deploy-LinuxConfiguration -Name '99-pssecurity-hardening.conf', '99-pssecurity-core.conf'
```

Deploys only the kernel parameters and the core dump policy, leaving the kernel
module blacklist out.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.IO.FileInfo. With -PassThru, one object per copied file. Otherwise
nothing.

