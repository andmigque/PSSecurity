# Get-SudoersAudit

*Audits sudo rules for passwordless, all-command, and wildcard grants.*

## DESCRIPTION

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

## PARAMETERS

### -LiteralPath

The main sudoers file. Defaults to /etc/sudoers.

## EXAMPLES

### Example 1

```powershell
Invoke-Sudo { Import-Module ./PSSecurity.psd1; Get-SudoersAudit }
```

Lists every sudo rule as root.

### Example 2

```powershell
Get-SudoersAudit | Where-Object { $_.NoPassword -or $_.Wildcard }
```

Lists the rules that skip the password prompt or match commands by wildcard.

### Example 3

```powershell
Get-SudoersAudit | Where-Object -Property AllCommand | Group-Object -Property User
```

Counts the rules per account that grant every command.

## INPUTS

None. You can't pipe objects to this function.

## OUTPUTS

System.Management.Automation.PSCustomObject. One object per user rule with Path,
LineNumber, User, NoPassword, AllCommand, Wildcard, and Rule.

