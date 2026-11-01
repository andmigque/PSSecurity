#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsLinux) {
    function Get-SudoersAudit {
        <#
        .SYNOPSIS
            Audits sudo rules for passwordless, all-command, and wildcard grants.

        .DESCRIPTION
            Reads the sudoers file and every file it includes, and returns one object per
            user rule with three flags:

            - NoPassword: the rule has the NOPASSWD tag, so the account escalates without
              proving anything it knows.
            - AllCommand: the rule grants ALL commands.
            - Wildcard: a command contains * or ?, which sudo matches against command paths
              and arguments alike, so a grant such as /usr/bin/find * matches far more than
              its literal text.

            Follows #include, @include, #includedir, and @includedir. Included directories
            skip file names that contain a dot or end in ~, as sudo does. Joins lines that
            end in a backslash, and treats # as a comment unless it starts an include or is
            followed by a digit, which is a user ID. Commands named through a Cmnd_Alias are
            resolved, so a wildcard or ALL behind an alias is still flagged. Defaults lines and
            alias definitions are not returned.

            Reads only the sudoers files, with no external tools, so it works with any
            sudo implementation that uses them. The files are readable by root only. Linux
            only.

        .PARAMETER LiteralPath
            The main sudoers file. Defaults to /etc/sudoers.

        .INPUTS
            None. You can't pipe objects to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object per user rule with Path,
            LineNumber, User, NoPassword, AllCommand, Wildcard, and Rule.

        .EXAMPLE
            Invoke-Sudo { Import-Module ./PSSecurity.psd1; Get-SudoersAudit }

            Lists every sudo rule as root.

        .EXAMPLE
            Get-SudoersAudit | Where-Object { $_.NoPassword -or $_.Wildcard }

            Lists the rules that skip the password prompt or match commands by wildcard.

        .EXAMPLE
            Get-SudoersAudit | Where-Object -Property AllCommand | Group-Object -Property User

            Counts the rules per account that grant every command.
        #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(HelpMessage = 'Enter the main sudoers file. Defaults to /etc/sudoers.')]
            [ValidateNotNullOrEmpty()]
            [string]$LiteralPath = '/etc/sudoers'
        )

        $pending = [System.Collections.Generic.Queue[string]]::new()
        $pending.Enqueue((Resolve-Path -LiteralPath $LiteralPath -ErrorAction Stop).ProviderPath)
        $visited = [System.Collections.Generic.HashSet[string]]::new()
        $statements = [System.Collections.Generic.List[PSCustomObject]]::new()

        while ($pending.Count -gt 0) {
            $path = $pending.Dequeue()
            if (-not $visited.Add($path)) {
                continue
            }

            $lines = @(Get-Content -LiteralPath $path -ErrorAction Stop)
            $parts = [System.Collections.Generic.List[string]]::new()
            for ($index = 0; $index -lt $lines.Count; $index++) {
                if ($parts.Count -eq 0) {
                    $startLine = $index + 1
                }

                # A trailing backslash continues the statement on the next line.
                if ($lines[$index] -match '\\$') {
                    $parts.Add($lines[$index].TrimEnd('\'))
                    continue
                }
                $parts.Add($lines[$index])
                $statement = ($parts -join ' ').Trim()
                $parts.Clear()

                if ($statement -match '^[#@](include|includedir)\s+"?([^"]+)"?$') {
                    $target = $Matches[2].Trim()
                    if (-not [System.IO.Path]::IsPathRooted($target)) {
                        $target = Join-Path -Path (Split-Path -Path $path -Parent) -ChildPath $target
                    }

                    if ($Matches[1] -eq 'include') {
                        $pending.Enqueue($target)
                    }
                    elseif (Test-Path -LiteralPath $target -PathType Container) {
                        Get-ChildItem -LiteralPath $target -File |
                            Where-Object -Property Name -NotMatch '\.|~$' |
                            Sort-Object -Property Name |
                            ForEach-Object { $pending.Enqueue($_.FullName) }
                    }
                    continue
                }

                # # starts a comment, except before a digit, where it is a user ID.
                $statement = ($statement -replace '(^|\s)#(?!\d).*$', '').Trim()
                if ($statement) {
                    $statements.Add([PSCustomObject]@{ Path = $path; LineNumber = $startLine; Text = $statement })
                }
            }
        }

        # Cmnd_Alias NAME = command, command : NAME2 = command
        $commandAlias = @{}
        foreach ($statement in $statements.Where({ $_.Text -match '^Cmnd_Alias\s+' })) {
            foreach ($definition in ($statement.Text -replace '^Cmnd_Alias\s+', '') -split '\s*:\s*') {
                $aliasName, $aliasCommand = $definition -split '\s*=\s*', 2
                $commandAlias[$aliasName.Trim()] = @($aliasCommand -split '\s*,\s*')
            }
        }

        $definitionPattern = '^(Defaults|User_Alias|Runas_Alias|Host_Alias|Cmnd_Alias|Cmd_Alias)\b'
        foreach ($statement in $statements.Where({ $_.Text -notmatch $definitionPattern -and $_.Text -match '=' })) {
            # Everything after the first = is the run-as list, tags, and commands.
            $commandText = ($statement.Text -split '=', 2)[1] -replace '\([^)]*\)', '' -replace '\b[A-Z_]+\s*:', ''

            $commands = [System.Collections.Generic.List[string]]::new()
            $unresolved = [System.Collections.Generic.Queue[string]]::new()
            foreach ($command in $commandText -split ',') {
                $unresolved.Enqueue($command.Trim())
            }
            $expandedAlias = [System.Collections.Generic.HashSet[string]]::new()
            while ($unresolved.Count -gt 0) {
                $command = $unresolved.Dequeue()
                $aliasName = $command.TrimStart('!')
                if ($commandAlias.ContainsKey($aliasName)) {
                    # The set stops an alias that names itself from expanding forever.
                    if ($expandedAlias.Add($aliasName)) {
                        $commandAlias[$aliasName] | ForEach-Object { $unresolved.Enqueue($_) }
                    }
                }
                elseif ($command) {
                    $commands.Add($command)
                }
            }

            [PSCustomObject]@{
                Path       = $statement.Path
                LineNumber = $statement.LineNumber
                User       = ($statement.Text -split '\s+', 2)[0]
                NoPassword = $statement.Text -match '\bNOPASSWD\s*:'
                AllCommand = $commands -contains 'ALL'
                Wildcard   = [bool]($commands -match '[*?]')
                Rule       = $statement.Text
            }
        }
    }
}
