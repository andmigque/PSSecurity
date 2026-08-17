using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

# Evaluated at discovery time so -Skip resolves while Pester builds the tree.
$IsElevatedHost = $false
if ($IsWindows) {
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsElevatedHost = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psm1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Get-ScheduledTaskAudit</h2>
####
#### Skipped off Windows. The task scheduler CIM classes do not exist there.
####
Describe 'Get-ScheduledTaskAudit' -Skip:(-not $IsWindows) {
    BeforeAll {
        # Warnings are captured rather than displayed, so an unelevated suite run
        # does not spray the elevation notice across every case.
        $script:audit = @(Get-ScheduledTaskAudit -WarningAction SilentlyContinue)
        $script:raw = @(Get-ScheduledTask -TaskPath '\*' -ErrorAction SilentlyContinue)
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - Regression: `$task.Actions.Execute` throws on COM handler actions, and the
    ####   throw kills the whole record. Row parity with the raw enumeration is what
    ####   catches tasks being dropped silently rather than erroring.
    It 'Returns one row per scheduled task, dropping none' {
        $script:audit.Count | Should -Be $script:raw.Count
        $script:audit.Count | Should -BeGreaterThan 0
    }

    #### - The documented field set is present on every row.
    It 'Projects the documented fields' {
        $expected = @(
            'TaskName', 'TaskPath', 'State', 'Author', 'RunAs', 'PrincipalKind',
            'LogonType', 'RunLevel', 'ActionKind', 'Runs',
            'LastRunTime', 'LastTaskResult', 'LastResultHex', 'LastResultKind', 'NextRunTime'
        )
        $names = @($script:audit[0].PSObject.Properties.Name)
        foreach ($field in $expected) {
            $names | Should -Contain $field
        }
    }

    #### - Regression: a principal is either a UserId or a GroupId. Reading only
    ####   UserId left roughly a third of rows with no identity, and said nothing.
    It 'Never leaves RunAs blank' {
        @($script:audit | Where-Object { [string]::IsNullOrWhiteSpace($_.RunAs) }).Count | Should -Be 0
    }

    #### - And names which of the two produced it.
    It 'Reports PrincipalKind as User or Group' {
        @($script:audit | Where-Object { $_.PrincipalKind -notin 'User', 'Group' }).Count | Should -Be 0
    }

    #### - Regression: COM handler tasks are the ones that used to disappear, so
    ####   their presence is the positive proof the switch handles both classes.
    It 'Includes COM handler tasks alongside exec tasks' {
        @($script:audit | Where-Object { $_.ActionKind -match 'ComHandler' }).Count | Should -BeGreaterThan 0
        @($script:audit | Where-Object { $_.ActionKind -match 'Exec' }).Count | Should -BeGreaterThan 0
    }

    #### - A COM action records its class id rather than an empty command line.
    It 'Records a ClassId for COM handler actions' {
        $com = @($script:audit | Where-Object { $_.ActionKind -eq 'ComHandler' })
        $com[0].Runs | Should -Match '^COM:'
    }

    #### - Every result classifies, and the hex form is what makes a code readable.
    It 'Classifies every result and renders it as hex' {
        @($script:audit | Where-Object { $_.LastResultKind -notin 'Success', 'Informational', 'Failure' }).Count | Should -Be 0
        @($script:audit | Where-Object { $_.LastResultHex -notmatch '^0x[0-9A-F]{8}$' }).Count | Should -Be 0
    }

    #### - Regression: `LastTaskResult -ne 0` is mostly false positives. The
    ####   scheduler's own informational range must not classify as failure.
    It 'Treats the 0x000413xx informational range as not a failure' {
        $informational = @($script:audit | Where-Object { $_.LastResultHex -like '0x000413*' })
        @($informational | Where-Object { $_.LastResultKind -eq 'Failure' }).Count | Should -Be 0
    }

    #### - A failure is exactly a set HRESULT severity bit, nothing else.
    It 'Classifies a result as Failure only when the severity bit is set' {
        foreach ($row in @($script:audit | Where-Object { $_.LastResultKind -eq 'Failure' })) {
            ([uint32]$row.LastTaskResult -band 0x80000000) | Should -Not -Be 0
        }
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">Get-ScheduledTaskAudit elevated</h2>
####
Describe 'Get-ScheduledTaskAudit elevated' -Skip:(-not ($IsWindows -and $IsElevatedHost)) {
    # One enumeration serves both cases, as in the unelevated block below.
    BeforeAll {
        $script:elevatedAudit = @(Get-ScheduledTaskAudit -WarningVariable elevationWarning -WarningAction SilentlyContinue)
        $script:elevatedWarning = @($elevationWarning)
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - An elevated session sees the whole machine, so it raises no warning.
    It 'Raises no elevation warning' {
        $script:elevatedWarning.Count | Should -Be 0
    }

    #### - SYSTEM context tasks are the ones an unelevated session cannot see, and
    ####   they are the bulk of what elevation buys.
    It 'Sees SYSTEM context tasks' {
        @($script:elevatedAudit | Where-Object { $_.RunAs -eq 'SYSTEM' }).Count | Should -BeGreaterThan 0
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">Get-ScheduledTaskAudit unelevated</h2>
####
Describe 'Get-ScheduledTaskAudit unelevated' -Skip:(-not ($IsWindows -and -not $IsElevatedHost)) {
    # One enumeration serves both cases. Each call walks every scheduled task over
    # CIM, and the audit and its warning come out of the same call anyway.
    BeforeAll {
        $script:unelevatedAudit = @(Get-ScheduledTaskAudit -WarningVariable elevationWarning -WarningAction SilentlyContinue)
        $script:unelevatedWarning = @($elevationWarning)
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The partial view must announce itself. Silence would present two thirds
    ####   of the machine as the whole of it, weighted toward the privileged end.
    It 'Warns that enumeration is incomplete' {
        $script:unelevatedWarning.Count | Should -BeGreaterThan 0
        [string]$script:unelevatedWarning[0] | Should -Match 'incomplete'
    }

    #### - It still returns what it can see. A partial audit beats no audit.
    It 'Still returns the tasks it can see' {
        $script:unelevatedAudit.Count | Should -BeGreaterThan 0
    }
}
####
#### ---
####
