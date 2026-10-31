PSSecurity.psd1 is used only for required powershell module data.
Config/Settings.psd1 contains all the settings for the application. There is a lot of hard to read linux bloat. We should devise a better strategy for configuration settings and files.
All files under Public and Private are .ps1. The .psm1 keeps Private .ps1 private through `Function:` before and after loading. 
Everything under Doc/ is generated documentation from the Convert-CommentHelpToMarkdown function.
The PwshProfile.ps1 in Config/ works on Win and Linux. You can setup your PSSecurity module by importing the module, then running: Deploy-PSProfile.
AGENTS.md contains general.
This repository uses minimal dependencies, ideally none.
Compress-FileTree provides interactive multi threaded progress. 
[Compress-FileTree](./Public/Compress-FileTree.ps1).

When you need to recurse and find files, choose between Get-FileSingleThreaded or Get-FileMultiThreaded based on the size of the filesystem you are recursing.

Invoke-ParallelJob uses a fixed pool of thread jobs. 

Use Test-Administrator and Assert-Administrator for functions that need admin. 

Functions like [Write-DirectoryHash](./Public/Write-DirectoryHash.ps1) use `$script:HashIndexInclude` . This is set in the .psm1 . However, this is kinda magical and not ideal. We should instead built a path to the config settings file, and set THAT as a $script on the module. Then all functions get the path and use the config they need. PSSecurity.psm1 has like 20 lines of $script. 

The Skill `cui-llm-redact` provides guidance on how to redeact and generalize CUI so that it is no longer CUI, and can be prompted into a public LLM.

The Pipeline directory has Azure pipeline `.yml` files.

We should probably start creating more folders in the Public directory to better organize by security domain, e.g. audit, harden