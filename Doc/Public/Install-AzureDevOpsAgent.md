# Install-AzureDevOpsAgent

*Downloads and registers an Azure Pipelines Windows agent as a service.*

## DESCRIPTION

Downloads the specified Windows agent release, prompts for a PAT through
config.cmd, and registers the agent as a Windows service that runs as
NETWORK SERVICE. Returns the service name, status, and start type.

An agent already configured at InstallPath for the same organization, pool,
and name is left intact and its service details are returned. A different
agent, or any other content in InstallPath, stops the installation.

Requires an elevated session. Supports -WhatIf and -Confirm. Windows only.

## PARAMETERS

### -OrganizationUrl

The Azure DevOps organization URL, such as https://dev.azure.com/example.

### -Pool

The name of an existing agent pool in the organization. Defaults to Default.

### -AgentName

The name used to register this agent in the pool. Defaults to the local
computer name.

### -InstallPath

An empty installation directory, or the directory of an already configured
matching agent. A missing directory is created. Defaults to C:\azagent.

### -WorkFolder

The agent work directory, relative to the installation directory or an
absolute path. Defaults to _work.

### -Architecture

The Windows agent package architecture, such as x64. Defaults to x64.

### -Version

The agent release version to download, such as 5.279.0. Defaults to 5.279.0.

## EXAMPLES

### Example 1

```powershell
Install-AzureDevOpsAgent -OrganizationUrl https://dev.azure.com/example
```

Installs the agent in C:\azagent using the Default pool and the local computer
name. Prompts for a PAT during registration.

### Example 2

```powershell
$agentParams = @{
    OrganizationUrl = 'https://dev.azure.com/example'
    Pool            = 'Build'
    AgentName       = 'Builder01'
    InstallPath     = 'C:\agents\builder01'
}
Install-AzureDevOpsAgent @agentParams
```

Registers Builder01 in the Build pool using C:\agents\builder01.

### Example 3

```powershell
Install-AzureDevOpsAgent -OrganizationUrl https://dev.azure.com/example -WhatIf
```

Checks the destination and reports the proposed installation, without
downloading files or registering a service.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. The Name, Status, and StartType
of the agent service. config.cmd also writes interactive text during
registration.

## NOTES

Create an organization-scoped PAT with Agent Pools (Read & manage) and enter
it at config.cmd's masked prompt. Microsoft's agent download endpoint must be
reachable. Build tools must be installed separately.

