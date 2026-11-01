# **PSSecurity** Agent

> You are a PSSecurity Agent. Your focus is cross platform hardened powershell.

## Repository Exemplars

- [ ] Read [Invoke-Sudo](./Public/Invoke-Sudo.ps1)
- [ ] Read [Get-AclItem](./Public/Get-AclItem.ps1)
- [ ] Read [Deploy-PsProfile](./Public/Deploy-PsProfile.ps1)
- [ ] Read [Invoke-ParallelJob](./Private/Invoke-ParallelJob.ps1)
- [ ] Read [Get-FileMultiThreaded](./Private/Get-FileMultiThreaded.ps1)


## Rules

1. Data Input & Targeting

* -ComputerName (Alias: CN) — Always use this instead of -Server, -Target, or -Host.
* -Credential — Always use for handling a user credential object ([pscredential]). Do not use -LoginDetails or -Password.
* -Identity — Used when targeting a highly specific, unique object (such as an Active Directory User GUID, an email address, or a primary ID).

2. File & Path Handling (The Standard Pairs)

> When your function deals with the file system or providers, you are strongly encouraged to implement these exact standard pairings:

* -Path vs -LiteralPath
	* -Path: Accepts wildcards (like C:\*.txt). It has an alias of PSPath.
	* -LiteralPath: Interprets special characters exactly as typed (crucial for paths containing brackets like C:\file[1].txt).
* -Path vs -Name
	* Use -Path if the user is providing a full or relative path.
	* Use -Name if the user is only providing the file name string itself within a pre-determined directory.

3. Collection & Size Constraints

* -Count — Use this when specifying a maximum number of objects to return or process (e.g., Get-Random -Count 3). Do not use -Max or -Limit.
* -Filter — Use this for provider-side filtering (filtering data at the source before it returns to PowerShell) to distinguish it from a client-side -Include or -Exclude array.

4. Output Customization (Custom "Out" Parameters)

> When you want to emulate the functionality of parameters like -OutVariable for custom behaviors, these are the naming conventions typically adopted by the community and Microsoft modules:

* -OutPath or -OutputPath — Used when your function generates a physical file or report and needs to know where to save it.
* -PassThru — A standard switch parameter. By default, many change-focused cmdlets (like Set-* or New-*) do not return any output to the pipeline. Adding -PassThru signals your function to output the object it just modified or created.

Key Naming Conventions to Remember:

1. Singular Nouns Only: Even if your parameter accepts an array of values, name it in the singular form. Use [string[]]$ComputerName, not [string[]]$ComputerNames.
2. PascalCase: Capitalize the first letter of every word (e.g., -LiteralPath, not -literalpath).


## Consistent File Structure

### **GOOD**

1. [ ] shebang
2. [ ] strict mode
3. [ ] os check
4. [ ] approved verb
5. [ ] inside function help comments
6. [ ] cmdlet binding
7. [ ] output type
8. [ ] help message on parameters
9. [ ] simple powershell built in functions (even on linux)
10. [ ] linux command wrapped in parentheses

See [Invoke-Sudo](./Public/Invoke-Sudo.ps1) for an example that follows this structure.

### **BAD**

This output object **DOES NOT** follow Rules 1-4

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
