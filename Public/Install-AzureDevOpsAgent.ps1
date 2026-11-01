#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Install-AzureDevOpsAgent {
        <#
        .SYNOPSIS
            Downloads and registers an Azure Pipelines Windows agent as a service.

        .DESCRIPTION
            Downloads the specified Windows agent release, prompts for a PAT through
            config.cmd, and registers the agent as a Windows service that runs as
            NETWORK SERVICE. Returns the service name, status, and start type.

            An agent already configured at InstallPath for the same organization, pool,
            and name is left intact and its service details are returned. A different
            agent, or any other content in InstallPath, stops the installation.

            Requires an elevated session. Supports -WhatIf and -Confirm. Windows only.

        .PARAMETER OrganizationUrl
            The Azure DevOps organization URL, such as https://dev.azure.com/example.

        .PARAMETER Pool
            The name of an existing agent pool in the organization. Defaults to Default.

        .PARAMETER AgentName
            The name used to register this agent in the pool. Defaults to the local
            computer name.

        .PARAMETER InstallPath
            An empty installation directory, or the directory of an already configured
            matching agent. A missing directory is created. Defaults to C:\azagent.

        .PARAMETER WorkFolder
            The agent work directory, relative to the installation directory or an
            absolute path. Defaults to _work.

        .PARAMETER Architecture
            The Windows agent package architecture, such as x64. Defaults to x64.

        .PARAMETER Version
            The agent release version to download, such as 5.279.0. Defaults to 5.279.0.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. The Name, Status, and StartType
            of the agent service. config.cmd also writes interactive text during
            registration.

        .EXAMPLE
            Install-AzureDevOpsAgent -OrganizationUrl https://dev.azure.com/example

            Installs the agent in C:\azagent using the Default pool and the local computer
            name. Prompts for a PAT during registration.

        .EXAMPLE
            $agentParams = @{
                OrganizationUrl = 'https://dev.azure.com/example'
                Pool            = 'Build'
                AgentName       = 'Builder01'
                InstallPath     = 'C:\agents\builder01'
            }
            Install-AzureDevOpsAgent @agentParams

            Registers Builder01 in the Build pool using C:\agents\builder01.

        .EXAMPLE
            Install-AzureDevOpsAgent -OrganizationUrl https://dev.azure.com/example -WhatIf

            Checks the destination and reports the proposed installation, without
            downloading files or registering a service.

        .NOTES
            Create an organization-scoped PAT with Agent Pools (Read & manage) and enter
            it at config.cmd's masked prompt. Microsoft's agent download endpoint must be
            reachable. Build tools must be installed separately.
        #>
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory, HelpMessage = 'Enter the Azure DevOps organization URL.')]
            [ValidateNotNullOrEmpty()]
            [string]$OrganizationUrl,

            [Parameter(HelpMessage = 'Enter the existing agent pool name. Defaults to Default.')]
            [ValidateNotNullOrEmpty()]
            [string]$Pool = 'Default',

            [Parameter(HelpMessage = 'Enter the agent name. Defaults to the local computer name.')]
            [ValidateNotNullOrEmpty()]
            [string]$AgentName = $env:COMPUTERNAME,

            [Parameter(HelpMessage = 'Enter the installation directory. Defaults to C:\azagent.')]
            [ValidateNotNullOrEmpty()]
            [string]$InstallPath = 'C:\azagent',

            [Parameter(HelpMessage = 'Enter the agent work directory. Defaults to _work.')]
            [ValidateNotNullOrEmpty()]
            [string]$WorkFolder = '_work',

            [Parameter(HelpMessage = 'Enter the Windows agent package architecture. Defaults to x64.')]
            [ValidateNotNullOrEmpty()]
            [string]$Architecture = 'x64',

            [Parameter(HelpMessage = 'Enter the agent release version. Defaults to 5.279.0.')]
            [ValidateNotNullOrEmpty()]
            [string]$Version = '5.279.0'
        )

        Assert-Administrator

        $ErrorActionPreference = 'Stop'
        $OrganizationUrl = $OrganizationUrl.TrimEnd('/')
        $InstallPath = [System.IO.Path]::GetFullPath($InstallPath)
        $configurationPath = Join-Path -Path $InstallPath -ChildPath '.agent'

        if (Test-Path -LiteralPath $configurationPath) {
            $existing = Get-Content -LiteralPath $configurationPath -Raw | ConvertFrom-Json
            if ($existing.serverUrl.TrimEnd('/') -ne $OrganizationUrl -or
                $existing.poolName -ne $Pool -or
                $existing.agentName -ne $AgentName) {
                throw "A different agent is configured at $InstallPath."
            }

            Write-Verbose -Message "Agent $AgentName is already configured for pool $Pool at $InstallPath."
            Get-Service -Name 'vstsagent*' -ErrorAction SilentlyContinue |
                Select-Object -Property Name, Status, StartType
            return
        }

        if ((Test-Path -LiteralPath $InstallPath) -and
            (Get-ChildItem -LiteralPath $InstallPath -Force | Select-Object -First 1)) {
            throw "InstallPath is not empty: $InstallPath."
        }

        if (-not $PSCmdlet.ShouldProcess($InstallPath, "Install and register agent $AgentName in pool $Pool")) {
            return
        }

        $archivePath = Join-Path -Path $env:TEMP -ChildPath 'azure-pipelines-agent.zip'
        $downloadUri = 'https://download.agent.dev.azure.com/agent/{0}/vsts-agent-win-{1}-{0}.zip?download=1' -f $Version, $Architecture
        Invoke-WebRequest -Uri $downloadUri -OutFile $archivePath
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
                throw "Agent configuration failed (exit $LASTEXITCODE)."
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
        $service.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running, [System.TimeSpan]::FromSeconds(30))

        Write-Verbose -Message "Agent $AgentName installed in $InstallPath; service is running."
        Write-Information -MessageData "Check online status: $OrganizationUrl/_settings/agentpools" -InformationAction Continue

        Get-Service -Name $serviceName | Select-Object -Property Name, Status, StartType
    }
}
