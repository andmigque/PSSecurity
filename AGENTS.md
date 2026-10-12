# Security Engineer Agent

> You are a Security Engineering agent. Your focus is cross platform hardened powershell.
> Your code is consistent, using the same input and output parameters and objects where possible
> You limit the input and output surface of your tool suite:


**PSSecurity**

## 1. BE CONSISTENT

- [ ] Read [Compress-FileTree](./Public/Compress-FileTree.ps1)
- [ ] Read [Get-ApplicationSignatureAudit](./Public/Get-ApplicationSignatureAudit.ps1)
- [ ] Read [Get-SuidBinary](./Public/Get-SuidBinary.ps1)
- [ ] See [Compress-FileTree Image](./Image/Compress-FileTree.png)

```powershell
Path            : /usr
OutPath         : /mnt/c/Users/Ondrezz/Develop/PSSecurity/Generated
TotalFiles      : 39244
CompressedFiles : 39193
FailedFiles     : 51
Errors          : {@{Path=/usr/share/locale/sv/LC_TIME/coreutils.mo; Message=Exception calling "OpenRead" with "1" argu
                  ment(s): "Could not find file '/usr/share/locale/sv/LC_TIME/coreutils.mo'."}, @{Path=/usr/share/local
                  e/et/LC_TIME/coreutils.mo; Message=Exception calling "OpenRead" with "1" argument(s): "Could not find
                   file '/usr/share/locale/et/LC_TIME/coreutils.mo'."}, @{Path=/usr/share/locale/eu/LC_TIME/coreutils.m
                  o; Message=Exception calling "OpenRead" with "1" argument(s): "Could not find file '/usr/share/locale
                  /eu/LC_TIME/coreutils.mo'."}, @{Path=/usr/share/locale/da/LC_TIME/coreutils.mo; Message=Exception cal
                  ling "OpenRead" with "1" argument(s): "Could not find file '/usr/share/locale/da/LC_TIME/coreutils.mo
                  '."}…}
```

**Path, OutPath, Total, Verb, Fail, Error**

That is about the maxium useful amount of output object. Any more than that, and you are likely not communicating well.

> Instead of Compressed, use `AuditFiles`, instead of `FailedFiles`, use `UnsignedFiles`, or `AnomalyDirectories`. 
> Choose an appropriate name within the adjacent neighborhood of taxonomies. 

This is too much, cluttered, unfocused information:

```powershell
 Get-SshdConfiguration

AuditStatus         : Complete
ConfigPath          : C:\ProgramData\ssh\sshd_config
ConnectionSpec      :
SshdPath            : C:\WINDOWS\System32\OpenSSH\sshd.exe
SshdVersion         : OpenSSH_for_Windows_9.5p2
ServiceName         : sshd
ServiceState        : Stopped
ServiceBinaryPath   : C:\WINDOWS\System32\OpenSSH\sshd.exe
ServiceConfigPath   :
RunningProcessPaths : {}
InstalledBinaries   : {@{Path=C:\Program Files\OpenSSH\sshd.exe; Version=OpenSSH_for_Windows_10.0p2},
                      @{Path=C:\WINDOWS\System32\OpenSSH\sshd.exe; Version=OpenSSH_for_Windows_9.5p2}}
KeywordCount        : 81
Warnings            : {Multiple sshd binaries are installed: C:\Program Files\OpenSSH\sshd.exe (OpenSSH_for_Windows_10.0p2),
                      C:\WINDOWS\System32\OpenSSH\sshd.exe (OpenSSH_for_Windows_9.5p2). The sshd service runs
                      'C:\WINDOWS\System32\OpenSSH\sshd.exe'.}
Settings            : {@{Keyword=addressfamily; Values=System.Object[]}, @{Keyword=allowagentforwarding; Values=System.Object[]},
                      @{Keyword=allowstreamlocalforwarding; Values=System.Object[]}, @{Keyword=allowtcpforwarding;
                      Values=System.Object[]}…}
```

Is this an audit? A configuration check? An ssh check? A service check? It's confusing because it's not consisten with already established norms.
AuditStatus is useless. 
SshdPath and ServiceBinaryPath are the same. Repeated again 5 more visible times. 

## 2. Cross Platform first, $IsLinux, $IsWindows Second

- [ ] Wrap your entire function so that the function doesn't get imported on unsupportred platforms.