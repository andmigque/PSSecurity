# if ($IsLinux) {
#     Set-StrictMode -Version Latest

#     function Get-SudoersAudit {
#         <#
#     .SYNOPSIS
#         Audits sudo policy for passwordless and wildcard grants.

#     .DESCRIPTION
#         Returns one report describing every user specification in the sudoers files, and flags
#         the grants that remove the password prompt or widen what a command can match. Passwordless
#         entries carry the NOPASSWD tag, so the granted account escalates without proving anything
#         it knows. Wildcards are shell-style patterns that sudo applies to command paths and to
#         arguments alike, so a grant such as /usr/bin/find * matches far more than its literal
#         text. Together they are the standard paths from a narrow sudo grant to an unintended
#         root shell.

#         The parser reads the main file and every file reached through #include, @include,
#         #includedir, and @includedir directives. It joins backslash continuations and strips
#         comments the way the sudoers grammar does. A # starts a comment unless it begins an
#         include directive or is immediately followed by a digit, which denotes a user ID.
#         Includedir names containing a dot or ending in a tilde are skipped, as sudo does.
#         Defined aliases are collected first, and each command is resolved through Cmnd_Alias
#         references with cycle and depth guards, so a wildcard or a passwordless tag hidden
#         behind an alias is still detected. Tags and runas targets persist across a
#         specification as sudo applies them, and alias expansion runs with its own state and
#         then restores the outer state.

#         Each result row reports the source location, granted user, host, runas target, command,
#         active tags, and flags: Passwordless, Wildcard, AllCommand, and RunasAll. Rows whose
#         canonical text matches the module's SudoersKnownGoodSpec setting are KnownGood; every
#         other passwordless or wildcard row is flagged for review in ReviewEntries. SourceFiles
#         carries each parsed file's mode, owner, and a Secure check for root ownership with the
#         mode 0440 that sudo itself enforces, so a loosened file is visible next to the grants
#         it defines.

#         The report is one object carrying coverage counters and an AuditStatus, so a scan with
#         no findings is never mistaken for a clean or complete result. sudoers files are readable
#         by root only, so a non-root session records access errors and returns AuditStatus
#         Incomplete. Pass -Elevate to re-run the audit as root through sudo for a complete report.

#     .PARAMETER SudoersFile
#         The main sudoers file to parse. Defaults to the module's SudoersFilePath setting from
#         Config/Setting.psd1.

#     .PARAMETER IncludeDirectory
#         The sudoers.d directory scanned after the main file and any include directives it names.
#         Defaults to the module's SudoersIncludeDirPath setting from Config/Setting.psd1.

#     .PARAMETER KnownGoodSpec
#         Specification patterns treated as reviewed and acceptable. Each pattern is matched with
#         wildcards against the row's canonical text, formatted as
#         'user host=(runas) [NOPASSWD: ]command' with single spaces, for example
#         'deploy ALL=(root) NOPASSWD: /usr/bin/systemctl restart nginx'. Defaults to the module's
#         SudoersKnownGoodSpec setting; passing this parameter replaces the default list, so @()
#         flags every passwordless and wildcard entry.

#     .PARAMETER Elevate
#         Re-runs the audit as root through sudo when the current session is not root, so root-only
#         sudoers files are read and the report can be Complete. sudo may prompt for a password.
#         Ignored when the session is already root.

#     .INPUTS
#         None. This function does not accept pipeline input.

#     .OUTPUTS
#         One PSCustomObject with AuditStatus, SudoersFile, IncludeDirectory, SourceFiles,
#         ParsedFiles, DefaultEntries, AliasEntries, TotalEntries, PasswordlessEntries,
#         WildcardEntries, AllCommandEntries, RunasAllEntries, KnownGoodEntries, FlaggedEntries,
#         InsecureFiles, ByUser, ReviewEntries, Results, and Errors. SourceFiles carries Path,
#         Exists, Mode, Owner, Secure, and Entries per parsed file. Results carries one row per
#         resolved command with SourceFile, LineNumber, Specification, User, Host, RunAs, Command,
#         Tags, Passwordless, Wildcard, AllCommand, RunasAll, UserAll, HostAll, ResolvedAliases,
#         and KnownGood. ReviewEntries contains the flagged rows only. ByUser groups the rows per
#         granted user. Errors contains Path, LineNumber, and Message for read, metadata, alias,
#         and parse failures. An empty sudoers policy returns zero counts and empty arrays.

#     .EXAMPLE
#         $report = Get-SudoersAudit
#         $report.ReviewEntries | Format-Table User, RunAs, Command

#         Audits the sudo policy and lists the passwordless and wildcard grants outside the
#         known-good list.

#     .EXAMPLE
#         $report = Get-SudoersAudit -Elevate
#         $report.SourceFiles | Format-Table Path, Mode, Owner, Secure

#         Reads the sudoers files as root and reviews file modes and ownership next to the grants.

#     .EXAMPLE
#         $report = Get-SudoersAudit -KnownGoodSpec 'deploy ALL=(root) NOPASSWD: /usr/bin/systemctl *'
#         $report.ReviewEntries

#         Audits the sudo policy while treating the deployment account's passwordless systemctl
#         grants as reviewed.

#     .NOTES
#         Runs on Linux only; in WSL, run it inside the target distribution. The default file,
#         include directory, and known-good list come from the SudoersFilePath,
#         SudoersIncludeDirPath, and SudoersKnownGoodSpec keys in Config/Setting.psd1, so the
#         known-good list is data you can tune per distribution. Defaults entries are counted but
#         not audited; a Defaults !authenticate grant is outside this audit's scope. Alias
#         resolution is bounded and unparseable lines are reported in Errors, so a line sudo would
#         reject never silently disappears from the report.
#     #>
#         [CmdletBinding()]
#         [OutputType([pscustomobject])]
#         param(
#             # The main sudoers file to parse. Defaults to the module's SudoersFilePath setting.
#             [Parameter(HelpMessage = 'Enter the sudoers file to parse. Defaults to the SudoersFilePath setting.')]
#             [ValidateNotNullOrEmpty()]
#             [string]$SudoersFile = $script:SudoersFilePath,

#             # The sudoers.d directory scanned after the main file and include directives.
#             [Parameter(HelpMessage = 'Enter the sudoers include directory. Defaults to the SudoersIncludeDirPath setting.')]
#             [ValidateNotNullOrEmpty()]
#             [string]$IncludeDirectory = $script:SudoersIncludeDirPath,

#             # Specification patterns treated as reviewed and acceptable.
#             [Parameter(HelpMessage = 'Enter known-good specification patterns. Defaults to the SudoersKnownGoodSpec setting.')]
#             [string[]]$KnownGoodSpec = $script:SudoersKnownGoodSpec,

#             # Re-run the audit as root through sudo when the current session is not root.
#             [Parameter(HelpMessage = 'Re-run the audit as root through sudo for a complete report.')]
#             [switch]$Elevate
#         )

#         $sessionIsRoot = (& id -u) -eq 0

#         if ($Elevate -and -not $sessionIsRoot) {
#             # Array parameters bind as one comma-separated value (PowerShell rejects a
#             # repeated parameter), so rebuild the invocation for the sudo child process.
#             $sudoersArg = "'$($SudoersFile.Replace("'", "''"))'"
#             $includeArg = "'$($IncludeDirectory.Replace("'", "''"))'"
#             $call = "Get-SudoersAudit -SudoersFile $sudoersArg -IncludeDirectory $includeArg"

#             if ($KnownGoodSpec.Count -eq 0) {
#                 $call += ' -KnownGoodSpec @()'
#             }
#             else {
#                 $knownGoodArg = ($KnownGoodSpec | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','
#                 $call += " -KnownGoodSpec $knownGoodArg"
#             }

#             Invoke-SudoCommand -Command $call
#             return
#         }

#         # sudo applies its own includedir rules to discovered files, and include directives may
#         # name single files as well as directories, so discovery walks a work queue while parsing.
#         $directivePattern = '^\s*[@#]include(dir)?\s+(\S+)'
#         $tagNames = 'NOPASSWD|PASSWD|NOEXEC|EXEC|SETENV|NOSETENV|MAIL|NOMAIL|FOLLOW|NOFOLLOW'
#         $tagNames = "$tagNames|LOG_INPUT|NOLOG_INPUT|LOG_OUTPUT|NOLOG_OUTPUT|INTERCEPT|NOINTERCEPT"
#         $tagPattern = "^($tagNames)\s*:"

#         $pendingFiles = [System.Collections.Generic.Queue[string]]::new()
#         $pendingDirectories = [System.Collections.Generic.Queue[string]]::new()
#         $visitedFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
#         $visitedDirectories = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

#         $pendingFiles.Enqueue($SudoersFile)
#         $pendingDirectories.Enqueue($IncludeDirectory)

#         $errors = [System.Collections.Generic.List[object]]::new()
#         $fileRecords = [System.Collections.Generic.List[PSCustomObject]]::new()
#         $entriesByFile = @{}
#         $aliasCommands = @{}
#         $aliasCount = 0
#         $defaultCount = 0
#         $parsedFileCount = 0
#         $accessDeniedCount = 0
#         $specLines = [System.Collections.Generic.List[PSCustomObject]]::new()

#         while ($pendingFiles.Count -gt 0 -or $pendingDirectories.Count -gt 0) {
#             if ($pendingFiles.Count -gt 0) {
#                 $filePath = $pendingFiles.Dequeue()
#                 if (-not $visitedFiles.Add($filePath)) {
#                     continue
#                 }

#                 $fileRecord = [PSCustomObject]@{
#                     Path    = $filePath
#                     Exists  = (Test-Path -LiteralPath $filePath -PathType Leaf)
#                     Mode    = 'Unknown'
#                     Owner   = 'Unknown'
#                     Secure  = $false
#                     Entries = 0
#                 }
#                 $fileRecords.Add($fileRecord)
#                 $entriesByFile[$filePath] = 0

#                 if (-not $fileRecord.Exists) {
#                     $errors.Add([pscustomobject]@{
#                             Path       = $filePath
#                             LineNumber = -1
#                             Message    = 'The sudoers file does not exist.'
#                         })
#                     continue
#                 }

#                 # One stat call per file covers the ownership and mode checks sudo itself applies.
#                 $statText = $null
#                 try {
#                     $statText = @(& stat -c '%a %u %U:%G' -- $filePath)[0]
#                     if ($LASTEXITCODE -ne 0) {
#                         $statText = $null
#                     }
#                 }
#                 catch {
#                     $statText = $null
#                 }

#                 if ($statText) {
#                     $statFields = @($statText -split ' ')
#                     if ($statFields.Count -ge 3) {
#                         $fileRecord.Mode = $statFields[0].PadLeft(4, '0')
#                         $fileRecord.Owner = $statFields[2]
#                         $fileRecord.Secure = ($statFields[1] -eq '0') -and ($statFields[0] -eq '440')
#                     }
#                     else {
#                         $errors.Add([pscustomobject]@{
#                                 Path       = $filePath
#                                 LineNumber = -1
#                                 Message    = 'Could not read the file metadata.'
#                             })
#                     }
#                 }
#                 else {
#                     $errors.Add([pscustomobject]@{
#                             Path       = $filePath
#                             LineNumber = -1
#                             Message    = 'Could not read the file metadata.'
#                         })
#                 }

#                 $rawLines = @()
#                 try {
#                     $rawLines = @(Get-Content -LiteralPath $filePath -ErrorAction Stop)
#                 }
#                 catch {
#                     $readDenied = $_.Exception -is [System.UnauthorizedAccessException] -or
#                     $_.Exception.InnerException -is [System.UnauthorizedAccessException]
#                     if ($readDenied) {
#                         $accessDeniedCount++
#                     }

#                     $errors.Add([pscustomobject]@{
#                             Path       = $filePath
#                             LineNumber = -1
#                             Message    = "Could not read the file: $($_.Exception.Message)"
#                         })
#                     continue
#                 }

#                 $parsedFileCount++

#                 # Comments are stripped per physical line, then backslash continuations are
#                 # joined, so a comment ends a logical line where sudo ends it and an include
#                 # directive is never read as a comment.
#                 $pendingText = ''
#                 $pendingStart = 0

#                 for ($lineIndex = 0; $lineIndex -lt $rawLines.Count; $lineIndex++) {
#                     $line = $rawLines[$lineIndex]
#                     $isContinuing = $pendingText.Length -gt 0
#                     $directiveMatch = $null

#                     if (-not $isContinuing) {
#                         $directiveMatch = [regex]::Match($line, $directivePattern)
#                     }

#                     if ($directiveMatch -and $directiveMatch.Success) {
#                         $target = $directiveMatch.Groups[2].Value
#                         if (-not [System.IO.Path]::IsPathRooted($target)) {
#                             $target = Join-Path -Path (Split-Path -Path $filePath -Parent) -ChildPath $target
#                         }

#                         if ($directiveMatch.Groups[1].Value) {
#                             $pendingDirectories.Enqueue($target)
#                         }
#                         else {
#                             $pendingFiles.Enqueue($target)
#                         }
#                         continue
#                     }

#                     $content = $line
#                     $commentIndex = -1
#                     for ($charIndex = 0; $charIndex -lt $content.Length; $charIndex++) {
#                         if ($content[$charIndex] -ne '#') {
#                             continue
#                         }

#                         if ($charIndex -gt 0 -and -not [char]::IsWhiteSpace($content[$charIndex - 1])) {
#                             continue
#                         }

#                         if ($charIndex + 1 -lt $content.Length -and [char]::IsDigit($content[$charIndex + 1])) {
#                             continue
#                         }

#                         $commentIndex = $charIndex
#                         break
#                     }

#                     if ($commentIndex -ge 0) {
#                         $content = $content.Substring(0, $commentIndex)
#                     }

#                     $content = $content.Trim()
#                     if ($pendingText.Length -eq 0) {
#                         $pendingStart = $lineIndex + 1
#                     }

#                     if ($content.EndsWith('\')) {
#                         $pendingText = ("$pendingText " + $content.Substring(0, $content.Length - 1)).Trim()
#                         continue
#                     }

#                     $fullText = ("$pendingText $content").Trim()
#                     $pendingText = ''
#                     if (-not $fullText) {
#                         continue
#                     }

#                     if ($fullText -match '^Defaults\b') {
#                         $defaultCount++
#                         continue
#                     }

#                     if ($fullText -match '^([A-Za-z][A-Za-z0-9_]*)_Alias\s') {
#                         $aliasMatch = [regex]::Match($fullText, '^([A-Za-z][A-Za-z0-9_]*)_Alias\s+(\S+)\s*=\s*(.+)$')
#                         if ($aliasMatch.Success) {
#                             $aliasKind = $aliasMatch.Groups[1].Value
#                             $aliasName = $aliasMatch.Groups[2].Value
#                             $aliasValue = $aliasMatch.Groups[3].Value
#                             $knownAliasKinds = @('Cmnd', 'User', 'Host', 'Runas')

#                             if ($knownAliasKinds -notcontains $aliasKind) {
#                                 $errors.Add([pscustomobject]@{
#                                         Path       = $filePath
#                                         LineNumber = $pendingStart
#                                         Message    = "Unknown alias kind: $($aliasKind)_Alias."
#                                     })
#                             }
#                             elseif ($aliasName -notmatch '^[A-Z][A-Z0-9_]*$') {
#                                 $errors.Add([pscustomobject]@{
#                                         Path       = $filePath
#                                         LineNumber = $pendingStart
#                                         Message    = "Invalid alias name: $aliasName. Alias names must be uppercase."
#                                     })
#                             }
#                             else {
#                                 $aliasCount++
#                                 if ($aliasKind -eq 'Cmnd') {
#                                     $aliasCommands[$aliasName] = @(Split-SudoersList -Value $aliasValue)
#                                 }
#                             }
#                         }
#                         else {
#                             $errors.Add([pscustomobject]@{
#                                     Path       = $filePath
#                                     LineNumber = $pendingStart
#                                     Message    = 'Could not parse the alias definition.'
#                                 })
#                         }
#                         continue
#                     }

#                     $specLines.Add([pscustomobject]@{
#                             Path       = $filePath
#                             LineNumber = $pendingStart
#                             Text       = $fullText
#                         })
#                 }
#             }
#             else {
#                 $directoryPath = $pendingDirectories.Dequeue()
#                 if (-not $visitedDirectories.Add($directoryPath)) {
#                     continue
#                 }

#                 if (-not (Test-Path -LiteralPath $directoryPath -PathType Container)) {
#                     Write-Verbose -Message "Include directory not found: $directoryPath"
#                     continue
#                 }

#                 try {
#                     $includedFiles = @(
#                         Get-ChildItem -LiteralPath $directoryPath -File -ErrorAction Stop |
#                             Sort-Object -Property Name
#                     )
#                 }
#                 catch {
#                     $errors.Add([pscustomobject]@{
#                             Path       = $directoryPath
#                             LineNumber = -1
#                             Message    = "Could not enumerate the include directory: $($_.Exception.Message)"
#                         })
#                     continue
#                 }

#                 foreach ($includedFile in $includedFiles) {
#                     if ($includedFile.Name.Contains('.') -or $includedFile.Name.EndsWith('~')) {
#                         Write-Verbose -Message "Skipping include file per sudo includedir rules: $($includedFile.Name)"
#                         continue
#                     }

#                     $pendingFiles.Enqueue($includedFile.FullName)
#                 }
#             }
#         }

#         # Phase two parses the collected user specifications now that every alias is known,
#         # because sudo resolves aliases at match time and an auditor should too.
#         $specRows = [System.Collections.Generic.List[PSCustomObject]]::new()

#         foreach ($specLine in $specLines) {
#             $specText = $specLine.Text
#             $splitIndex = $specText.IndexOf('=')
#             if ($splitIndex -lt 1) {
#                 $errors.Add([pscustomobject]@{
#                         Path       = $specLine.Path
#                         LineNumber = $specLine.LineNumber
#                         Message    = 'Could not parse the line as a user specification.'
#                     })
#                 continue
#             }

#             $left = $specText.Substring(0, $splitIndex).Trim()
#             $right = $specText.Substring($splitIndex + 1).Trim()
#             $leftTokens = @(($left -replace ',', ', ') -split '\s+' | Where-Object { $_ })

#             if ($leftTokens.Count -lt 2) {
#                 $errors.Add([pscustomobject]@{
#                         Path       = $specLine.Path
#                         LineNumber = $specLine.LineNumber
#                         Message    = 'The user specification has no host list.'
#                     })
#                 continue
#             }

#             $userTokens = [System.Collections.Generic.List[string]]::new()
#             $tokenIndex = 0
#             while ($tokenIndex -lt $leftTokens.Count -and $leftTokens[$tokenIndex].EndsWith(',')) {
#                 $userToken = $leftTokens[$tokenIndex].TrimEnd(',')
#                 if ($userToken) {
#                     $userTokens.Add($userToken)
#                 }
#                 $tokenIndex++
#             }

#             if ($tokenIndex -lt $leftTokens.Count) {
#                 $userTokens.Add($leftTokens[$tokenIndex])
#                 $tokenIndex++
#             }
#             else {
#                 $errors.Add([pscustomobject]@{
#                         Path       = $specLine.Path
#                         LineNumber = $specLine.LineNumber
#                         Message    = 'The user specification has no host list.'
#                     })
#                 continue
#             }

#             $hostTokens = @($leftTokens[$tokenIndex..($leftTokens.Count - 1)])
#             $userText = ($userTokens -join ', ')
#             $hostText = ($hostTokens -join ' ')

#             # Walk the right side as sudo does: runas targets and tags persist across the whole
#             # specification until overridden, including through alias expansion, and each alias
#             # expands with its own state before the outer state is restored.
#             $runasDisplay = 'root'
#             $runasUsers = @('root')
#             $runasGroups = @()
#             $runasAll = $false
#             $tagState = [ordered]@{}
#             $expansionErrorReported = $false

#             $specPieces = @(Split-SudoersList -Value $right)
#             if ($specPieces.Count -eq 0) {
#                 $errors.Add([pscustomobject]@{
#                         Path       = $specLine.Path
#                         LineNumber = $specLine.LineNumber
#                         Message    = 'The user specification has no commands.'
#                     })
#                 continue
#             }

#             $workItems = [System.Collections.Generic.Stack[PSCustomObject]]::new()
#             for ($pieceIndex = $specPieces.Count - 1; $pieceIndex -ge 0; $pieceIndex--) {
#                 $workItems.Push([pscustomobject]@{
#                         Text         = $specPieces[$pieceIndex]
#                         AliasPath    = @()
#                         RestoreState = $null
#                     })
#             }

#             while ($workItems.Count -gt 0) {
#                 $item = $workItems.Pop()

#                 if ($item.RestoreState) {
#                     $tagState = [ordered]@{}
#                     foreach ($stateKey in $item.RestoreState.TagState.Keys) {
#                         $tagState[$stateKey] = $item.RestoreState.TagState[$stateKey]
#                     }
#                     $runasDisplay = $item.RestoreState.RunasDisplay
#                     $runasUsers = $item.RestoreState.RunasUsers
#                     $runasGroups = $item.RestoreState.RunasGroups
#                     $runasAll = $item.RestoreState.RunasAll
#                     continue
#                 }

#                 $itemText = $item.Text

#                 while ($true) {
#                     if ($itemText.StartsWith('(')) {
#                         $closingIndex = $itemText.IndexOf(')')
#                         if ($closingIndex -lt 0) {
#                             $errors.Add([pscustomobject]@{
#                                     Path       = $specLine.Path
#                                     LineNumber = $specLine.LineNumber
#                                     Message    = 'The runas specification is not closed.'
#                                 })
#                             break
#                         }

#                         $runasInner = $itemText.Substring(1, $closingIndex - 1).Trim()
#                         $runasUsers = @()
#                         $runasGroups = @()
#                         $colonIndex = $runasInner.IndexOf(':')
#                         if ($colonIndex -ge 0) {
#                             $userPart = $runasInner.Substring(0, $colonIndex).Trim()
#                             $groupPart = $runasInner.Substring($colonIndex + 1).Trim()
#                             if ($userPart) {
#                                 $runasUsers = @($userPart -split '\s*,\s*' | Where-Object { $_ })
#                             }
#                             if ($groupPart) {
#                                 $runasGroups = @($groupPart -split '\s*,\s*' | Where-Object { $_ })
#                             }
#                         }
#                         else {
#                             $runasUsers = @($runasInner -split '\s*,\s*' | Where-Object { $_ })
#                         }

#                         $runasDisplay = ($runasUsers -join ', ')
#                         if ($runasGroups.Count -gt 0) {
#                             $runasDisplay = '{0}:{1}' -f $runasDisplay, ($runasGroups -join ', ')
#                         }

#                         $runasAll = $false
#                         foreach ($runasToken in @($runasUsers + $runasGroups)) {
#                             if ($runasToken -eq 'ALL' -or $runasToken.Contains('*')) {
#                                 $runasAll = $true
#                             }
#                         }

#                         $itemText = $itemText.Substring($closingIndex + 1).Trim()
#                         continue
#                     }

#                     $tagMatch = [regex]::Match($itemText, $tagPattern)
#                     if ($tagMatch.Success) {
#                         $tagName = $tagMatch.Groups[1].Value
#                         $tagState[($tagName -replace '^NO', '')] = ($tagName -notmatch '^NO')
#                         $itemText = $itemText.Substring($tagMatch.Length).Trim()
#                         continue
#                     }

#                     break
#                 }

#                 if (-not $itemText) {
#                     continue
#                 }

#                 $candidateTokens = @($itemText -split '\s+')
#                 $aliasLookup = $candidateTokens[0]
#                 $negated = $false
#                 if ($aliasLookup.StartsWith('!')) {
#                     $aliasLookup = $aliasLookup.Substring(1)
#                     $negated = $true
#                 }

#                 if ($candidateTokens.Count -eq 1 -and $aliasCommands.ContainsKey($aliasLookup)) {
#                     if ($item.AliasPath -contains $aliasLookup -or $item.AliasPath.Count -ge 16) {
#                         if (-not $expansionErrorReported) {
#                             $expansionErrorReported = $true
#                             $expansionMessage = "Cmnd_Alias $aliasLookup is part of a reference cycle."
#                             if ($item.AliasPath.Count -ge 16) {
#                                 $expansionMessage = "Cmnd_Alias $aliasLookup nesting exceeds 16 levels."
#                             }

#                             $errors.Add([pscustomobject]@{
#                                     Path       = $specLine.Path
#                                     LineNumber = $specLine.LineNumber
#                                     Message    = $expansionMessage
#                                 })
#                         }
#                         continue
#                     }

#                     $memberPieces = @($aliasCommands[$aliasLookup])
#                     if ($memberPieces.Count -eq 0) {
#                         $errors.Add([pscustomobject]@{
#                                 Path       = $specLine.Path
#                                 LineNumber = $specLine.LineNumber
#                                 Message    = "Cmnd_Alias $aliasLookup is empty."
#                             })
#                         continue
#                     }

#                     $restoredTags = [ordered]@{}
#                     foreach ($stateKey in @($tagState.Keys)) {
#                         $restoredTags[$stateKey] = $tagState[$stateKey]
#                     }

#                     $workItems.Push([pscustomobject]@{
#                             Text         = ''
#                             AliasPath    = $item.AliasPath
#                             RestoreState = [pscustomobject]@{
#                                 TagState     = $restoredTags
#                                 RunasDisplay = $runasDisplay
#                                 RunasUsers   = $runasUsers
#                                 RunasGroups  = $runasGroups
#                                 RunasAll     = $runasAll
#                             }
#                         })

#                     for ($memberIndex = $memberPieces.Count - 1; $memberIndex -ge 0; $memberIndex--) {
#                         $memberText = $memberPieces[$memberIndex]
#                         if ($negated) {
#                             $memberText = '!' + $memberText
#                         }

#                         $workItems.Push([pscustomobject]@{
#                                 Text         = $memberText
#                                 AliasPath    = ($item.AliasPath + $aliasLookup)
#                                 RestoreState = $null
#                             })
#                     }
#                     continue
#                 }

#                 if (-not $itemText -or -not $candidateTokens[0]) {
#                     $errors.Add([pscustomobject]@{
#                             Path       = $specLine.Path
#                             LineNumber = $specLine.LineNumber
#                             Message    = 'The specification contains an empty command element.'
#                         })
#                     continue
#                 }

#                 $wildcard = $itemText.Contains('*') -or $itemText.Contains('?') -or $itemText.Contains('[')
#                 $allCommand = ($candidateTokens[0] -eq 'ALL')

#                 $activeTags = [System.Collections.Generic.List[string]]::new()
#                 foreach ($stateKey in $tagState.Keys) {
#                     if ($tagState[$stateKey]) {
#                         $activeTags.Add($stateKey)
#                     }
#                     else {
#                         $activeTags.Add('NO' + $stateKey)
#                     }
#                 }

#                 $specRows.Add([pscustomobject]@{
#                         SourceFile      = $specLine.Path
#                         LineNumber      = $specLine.LineNumber
#                         Specification   = $specText
#                         User            = $userText
#                         Host            = $hostText
#                         RunAs           = $runasDisplay
#                         Command         = $itemText
#                         Tags            = $activeTags.ToArray()
#                         Passwordless    = ($tagState.Contains('PASSWD') -and (-not $tagState['PASSWD']))
#                         Wildcard        = $wildcard
#                         AllCommand      = $allCommand
#                         RunasAll        = $runasAll
#                         UserAll         = ($userTokens -contains 'ALL')
#                         HostAll         = ($hostTokens -contains 'ALL')
#                         ResolvedAliases = $item.AliasPath
#                         KnownGood       = $false
#                     })
#                 $entriesByFile[$specLine.Path] = $entriesByFile[$specLine.Path] + 1
#             }
#         }

#         $rows = @($specRows | Sort-Object -Property SourceFile, LineNumber, Command)

#         foreach ($fileRecord in $fileRecords) {
#             $fileRecord.Entries = $entriesByFile[$fileRecord.Path]
#         }

#         # Known-good patterns are matched against the canonical row text so spacing variations in
#         # the source file never decide whether an entry counts as reviewed.
#         foreach ($row in $rows) {
#             $matchedText = '{0} {1}=({2}) {3}' -f $row.User, $row.Host, $row.RunAs, $row.Command
#             if ($row.Passwordless) {
#                 $matchedText = '{0} {1}=({2}) NOPASSWD: {3}' -f $row.User, $row.Host, $row.RunAs, $row.Command
#             }

#             foreach ($pattern in $KnownGoodSpec) {
#                 if ($matchedText -like $pattern) {
#                     $row.KnownGood = $true
#                     break
#                 }
#             }
#         }

#         $passwordlessEntries = @($rows | Where-Object { $_.Passwordless }).Count
#         $wildcardEntries = @($rows | Where-Object { $_.Wildcard }).Count
#         $allCommandEntries = @($rows | Where-Object { $_.AllCommand }).Count
#         $runasAllEntries = @($rows | Where-Object { $_.RunasAll }).Count
#         $knownGoodEntries = @($rows | Where-Object { $_.KnownGood }).Count
#         $reviewRows = @($rows | Where-Object { (-not $_.KnownGood) -and ($_.Passwordless -or $_.Wildcard) })
#         $insecureFiles = @($fileRecords | Where-Object { $_.Exists -and $_.Mode -ne 'Unknown' -and (-not $_.Secure) }).Count

#         $byUser = [System.Collections.Generic.List[object]]::new()
#         foreach ($userGroup in ($rows | Group-Object -Property User | Sort-Object -Property Count -Descending)) {
#             $byUser.Add([pscustomobject]@{
#                     Name         = $userGroup.Name
#                     Entries      = $userGroup.Count
#                     Passwordless = @($userGroup.Group | Where-Object { $_.Passwordless }).Count
#                     Wildcard     = @($userGroup.Group | Where-Object { $_.Wildcard }).Count
#                 })
#         }

#         $auditStatus = 'Complete'
#         if ($errors.Count -gt 0) {
#             $auditStatus = 'Incomplete'
#         }

#         if ($accessDeniedCount -gt 0) {
#             $accessSummary = 'Could not read {0} sudoers files due to insufficient permissions.' -f $accessDeniedCount
#             $accessSummary += ' Re-run with -Elevate for a complete audit.'
#             Write-Warning -Message $accessSummary
#         }

#         [pscustomobject]@{
#             AuditStatus         = $auditStatus
#             SudoersFile         = $SudoersFile
#             IncludeDirectory    = $IncludeDirectory
#             SourceFiles         = $fileRecords.ToArray()
#             ParsedFiles         = $parsedFileCount
#             DefaultEntries      = $defaultCount
#             AliasEntries        = $aliasCount
#             TotalEntries        = $rows.Count
#             PasswordlessEntries = $passwordlessEntries
#             WildcardEntries     = $wildcardEntries
#             AllCommandEntries   = $allCommandEntries
#             RunasAllEntries     = $runasAllEntries
#             KnownGoodEntries    = $knownGoodEntries
#             FlaggedEntries      = $reviewRows.Count
#             InsecureFiles       = $insecureFiles
#             ByUser              = $byUser.ToArray()
#             ReviewEntries       = $reviewRows
#             Results             = $rows
#             Errors              = $errors.ToArray()
#         }
#     }
# }
