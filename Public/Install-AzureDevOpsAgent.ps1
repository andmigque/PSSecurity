#Requires -Version 5.1

Set-StrictMode -Version Latest

function Install-AzureDevOpsAgent {
    <#
    .SYNOPSIS
    Downloads and registers an Azure Pipelines Windows agent as a service.

    .DESCRIPTION
    Downloads the specified Windows agent release, prompts for a PAT through config.cmd,
    and registers the agent as a Windows service. Returns the service name, status, and start type.
    Use -WhatIf to preview the installation or -Confirm to confirm it before downloading files.

    .INPUTS
    None. This script does not accept pipeline input.

    .OUTPUTS
    System.Management.Automation.PSCustomObject
    Selected service properties: Name, Status, and StartType. The configuration command also
    writes interactive text during registration.

    .EXAMPLE
    .\Install-AzureDevOpsAgent.ps1 -OrganizationUrl https://dev.azure.com/example

    Installs the agent in C:\azagent using the Default pool and the local computer name.
    Prompts for a PAT during registration, then outputs Name, Status, and StartType for the service.

    .EXAMPLE
    $parameters = @{
        OrganizationUrl = 'https://dev.azure.com/example'
        Pool = 'Build'
        AgentName = 'Builder01'
        InstallPath = 'C:\agents\builder01'
    }
    .\Install-AzureDevOpsAgent.ps1 @parameters

    Registers Builder01 in the Build pool using C:\agents\builder01. Displays configuration text
    during registration, then outputs Name, Status, and StartType for the service.

    .EXAMPLE
    .\Install-AzureDevOpsAgent.ps1 -OrganizationUrl https://dev.azure.com/example -WhatIf

    Reports the proposed installation after checking the destination. Does not download files
    or register a service. An already configured matching agent returns existing service details.

    .NOTES
    Run in Administrator PowerShell. Create an organization-scoped PAT with
    Agent Pools (Read & manage). Enter the token at config.cmd's masked prompt.
    Microsoft's agent download endpoint must be reachable.
    An existing configured agent is left intact. Build tools must be installed separately.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        # Azure DevOps organization URL, such as https://dev.azure.com/example. Required; no default.
        [Parameter(Mandatory,
            HelpMessage = 'Enter the Azure DevOps organization URL.')]
        [ValidateNotNullOrEmpty()]
        [string]$OrganizationUrl,

        # Name of an existing agent pool in the organization. Defaults to Default.
        [Parameter(HelpMessage = 'Enter the existing agent pool name. Defaults to Default.')]
        [ValidateNotNullOrEmpty()]
        [string]$Pool = 'Default',

        # Name used to register this agent in the pool. Defaults to the local computer name.
        [Parameter(HelpMessage = 'Enter the agent name. Defaults to the local computer name.')]
        [ValidateNotNullOrEmpty()]
        [string]$AgentName = $env:COMPUTERNAME,

        # Empty installation directory, or the directory of an already configured matching agent.
        # Defaults to C:\azagent. A missing directory is created during installation.
        [Parameter(HelpMessage = 'Enter the installation directory. Defaults to C:\azagent.')]
        [ValidateNotNullOrEmpty()]
        [string]$InstallPath = 'C:\azagent',

        # Agent work directory, relative to the installation directory or an absolute path.
        # Defaults to _work within the installation directory.
        [Parameter(HelpMessage = 'Enter the agent work directory. Defaults to _work.')]
        [ValidateNotNullOrEmpty()]
        [string]$WorkFolder = '_work',

        # Windows agent package architecture identifier, such as x64. Defaults to x64.
        [Parameter(HelpMessage = 'Enter the Windows agent package architecture. Defaults to x64.')]
        [ValidateNotNullOrEmpty()]
        [string]$Architecture = 'x64',

        # Published agent release version to download, such as 5.279.0. Defaults to 5.279.0.
        [Parameter(HelpMessage = 'Enter the agent release version. Defaults to 5.279.0.')]
        [ValidateNotNullOrEmpty()]
        [string]$Version = '5.279.0'
    )

    $ErrorActionPreference = 'Stop'
    $OrganizationUrl = $OrganizationUrl.TrimEnd('/')
    $InstallPath = [IO.Path]::GetFullPath($InstallPath)
    $configurationPath = Join-Path -Path $InstallPath -ChildPath '.agent'

    if (Test-Path -LiteralPath $configurationPath) {
        $existing = Get-Content -LiteralPath $configurationPath -Raw | ConvertFrom-Json
        if ($existing.serverUrl.TrimEnd('/') -ne $OrganizationUrl -or
            $existing.poolName -ne $Pool -or $existing.agentName -ne $AgentName) {
            $message = 'A different agent is configured at {0}.' -f $InstallPath
            throw $message
        }
        $message = 'Agent {0} is already configured for pool {1} at {2}.' -f $AgentName, $Pool, $InstallPath
        Write-Verbose -Message $message
        Get-Service -Name 'vstsagent*' -ErrorAction SilentlyContinue |
        Select-Object -Property Name, Status, StartType
        return
    }

    if ((Test-Path -LiteralPath $InstallPath) -and
        (Get-ChildItem -LiteralPath $InstallPath -Force | Select-Object -First 1)) {
        $message = 'InstallPath is not empty: {0}.' -f $InstallPath
        throw $message
    }

    $action = 'Install and register agent {0} in pool {1}' -f $AgentName, $Pool
    if (-not $PSCmdlet.ShouldProcess($InstallPath, $action)) {
        return
    }

    # Windows PowerShell uses ServicePointManager to enable TLS 1.2 for the download.
    [Net.ServicePointManager]::SecurityProtocol =
    [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $archivePath = Join-Path -Path $env:TEMP -ChildPath 'azure-pipelines-agent.zip'
    $downloadUri = 'https://download.agent.dev.azure.com/agent/{0}/vsts-agent-win-{1}-{0}.zip?download=1' -f $Version, $Architecture
    Invoke-WebRequest -Uri $downloadUri -OutFile $archivePath -UseBasicParsing
    [void](New-Item -ItemType Directory -Path $InstallPath -Force)
    Expand-Archive -LiteralPath $archivePath -DestinationPath $InstallPath

    Push-Location -LiteralPath $InstallPath

    try {
        # The agent's configuration command handles registration and the masked PAT prompt.
        $configurationArguments = @(
            '--url', $OrganizationUrl
            '--auth', 'PAT'
            '--pool', $Pool
            '--agent', $AgentName
            '--work', $WorkFolder
            '--runAsService'
            '--windowsLogonAccount', 'NT AUTHORITY\NETWORK SERVICE'
        )

        & .\config.cmd @configurationArguments

        if ($LASTEXITCODE -ne 0) {
            $message = 'Agent configuration failed (exit {0}).' -f $LASTEXITCODE
            Write-Error $message
            throw
        }
    }
    finally {
        Pop-Location
    }

    $serviceMetadata = Join-Path -Path $InstallPath -ChildPath '.service'

    if (-not (Test-Path -LiteralPath $serviceMetadata)) {
        throw 'Configuration completed without expected service metadata.'
    }

    $serviceName = (Get-Content -LiteralPath $serviceMetadata -Raw).Trim()
    $service = Get-Service -Name $serviceName
    $service.WaitForStatus([ServiceProcess.ServiceControllerStatus]::Running, [TimeSpan]::FromSeconds(30))

    $message = 'Agent {0} installed in {1}; service is running.' -f $AgentName, $InstallPath

    Write-Verbose -Message $message

    $message = 'Check online status: {0}/_settings/agentpools' -f $OrganizationUrl

    Write-Information -MessageData $message -InformationAction Continue

    Get-Service -Name $serviceName | Select-Object -Property Name, Status, StartType

}
