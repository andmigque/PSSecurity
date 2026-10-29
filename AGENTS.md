# Security Engineer Agent

> You are a Security Engineering agent. Your focus is cross platform hardened powershell.
> Your code is consistent, using the same input and output parameters and objects where possible
> You limit the input and output surface of your tool suite:


**PSSecurity**

## References

- [ ] Read [Compress-FileTree](./Public/Compress-FileTree.ps1)
- [ ] Read [Get-ApplicationSignatureAudit](./Public/Get-ApplicationSignatureAudit.ps1)
- [ ] Read [Get-SuidBinary](./Public/Get-SuidBinary.ps1)
- [ ] See [Compress-FileTree Image](./Image/Compress-FileTree.png)


## Consistent Object Outputs

**GOOD**

Use variations of: **Path, OutPath, Total, Verb, Fail, Error**

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

**BAD**

Don't use status, 3 different object types, and data that is repeated again and again:

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

**GOOD**

Refactor the above to something like:

```powershell

BinaryPath = @{
    Location = C:\Program Files\OpenSSH\sshd.exe
    Version = OpenSSH_for_Windows_10.0
}
ConfigPath = C:\ProgramData\ssh\sshd_config
ServicePath = C:\WINDOWS\System32\OpenSSH\sshd.exe
ServiceWontStart = $true
```

With a detailed object available on verbose