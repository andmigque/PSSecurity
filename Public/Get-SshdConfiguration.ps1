#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Get-SshdConfiguration {
    <#
    .SYNOPSIS
        Gets the effective SSH daemon configuration as objects.

    .DESCRIPTION
        Runs sshd -T and returns one object per line of the dump. sshd -T resolves
        Include files, Match blocks, and defaults into the settings the daemon
        actually enforces, so the result reflects what runs rather than what any one
        file says. Keywords are lowercase, as sshd prints them. A keyword that can
        repeat, such as hostkey, returns one object per value.

        sshd -T reads the host private keys, so it usually needs root or an elevated
        session. Throws with sshd's error output when sshd fails, for example when the
        host keys can't be read or the configuration has a syntax error. When sshd
        reports a missing privilege separation directory, such as /run/sshd, the error
        explains how to create it.

    .PARAMETER ConnectionSpec
        Evaluates Match blocks for a described connection, in the sshd -C format, for
        example 'user=root,host=10.0.0.5,addr=10.0.0.5'. Without it, the result covers
        the global configuration only.

    .INPUTS
        None. You can't pipe objects to this function.

    .OUTPUTS
        System.Management.Automation.PSCustomObject. One object per setting with
        Keyword and Value.

    .EXAMPLE
        Get-SshdConfiguration | Where-Object -Property Keyword -EQ 'permitrootlogin'

        Shows whether root can log in.

    .EXAMPLE
        Get-SshdConfiguration -ConnectionSpec 'user=admin,host=10.0.0.5,addr=10.0.0.5' |
            Where-Object -Property Keyword -In 'permitrootlogin', 'passwordauthentication', 'x11forwarding'

        Shows the authentication settings that apply to one connection, after Match
        blocks.

    .EXAMPLE
        Get-SshdConfiguration | Where-Object -Property Keyword -EQ 'hostkey' | Select-Object -ExpandProperty Value

        Lists every host key file.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(HelpMessage = 'Connection to evaluate Match blocks for, such as user=root,host=10.0.0.5,addr=10.0.0.5.')]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionSpec
    )

    # Debian keeps sshd in /usr/sbin, which is not on a regular user's PATH.
    $sshd = @(Get-Command -Name sshd, /usr/sbin/sshd -CommandType Application -ErrorAction SilentlyContinue)
    if ($sshd.Count -eq 0) {
        throw 'Get-SshdConfiguration requires sshd, the OpenSSH server, which was not found.'
    }

    $sshdArguments = @(
        '-T'
        if ($PSBoundParameters.ContainsKey('ConnectionSpec')) {
            '-C', $ConnectionSpec
        }
    )

    $dump = (& $sshd[0].Source @sshdArguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        $sshdError = $dump -join ' '

        # The ssh service creates this directory when it starts, so it is missing where sshd has never run, as in WSL.
        if ($sshdError -match 'Missing privilege separation directory: (\S+)') {
            $privilegeDirectory = $Matches[1]
            $guidance = @"
sshd -T requires $privilegeDirectory, which the ssh service creates when it starts.
Start the service, then retry:

    sudo systemctl start ssh     # Debian, Ubuntu
    sudo systemctl start sshd    # RHEL, Fedora, Arch

Or create the directory without starting the service:

    sudo mkdir -p $privilegeDirectory
"@
            throw $guidance
        }

        throw "sshd -T failed (exit $LASTEXITCODE): $sshdError"
    }

    foreach ($line in $dump) {
        $keyword, $value = "$line".Split(' ', 2)
        [PSCustomObject]@{
            Keyword = $keyword
            Value   = [string]$value
        }
    }
}
