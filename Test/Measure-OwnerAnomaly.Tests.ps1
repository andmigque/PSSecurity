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

#### <h2 style="color: #DCA657;">Measure-OwnerAnomaly</h2>
####
Describe 'Measure-OwnerAnomaly' -Skip:(-not $IsWindows) {
    BeforeAll {
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:dir | Out-Null
        foreach ($leaf in 'one.txt', 'two.txt', 'three.txt') {
            Set-Content -LiteralPath (Join-Path $script:dir $leaf) -Value 'x' -NoNewline
        }
        $script:items = @(Get-ChildItem -LiteralPath $script:dir -File | ForEach-Object { $_.FullName | Get-AclItem })

        # Read the owner off disk rather than assuming it. Local policy decides
        # whether an admin-created file is owned by the account or by Administrators.
        $script:actualOwner = $script:items[0].Owner
        $script:foreignIdentity = 'NOSUCHDOMAIN\nosuchprincipal'
    }
    AfterAll {
        Remove-Item -LiteralPath $script:dir -Recurse -Force -ErrorAction SilentlyContinue
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'Measure-OwnerAnomaly' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }

    #### - One object for the whole pipeline. This is the accumulator contract.
    It 'Emits exactly one summary object for the whole pipeline' {
        # Regression: an accumulator backed by ArrayList leaks Add()'s index
        # onto the success stream, one integer per input, ahead of the summary.
        @($script:items | Measure-OwnerAnomaly).Count | Should -Be 1
    }

    #### - Every input is counted, whether or not it was an anomaly.
    It 'Counts every item that came down the pipeline' {
        ($script:items | Measure-OwnerAnomaly).AclItemCount | Should -Be $script:items.Count
    }

    #### - A matching identity produces no anomalies at all.
    It 'Reports no anomaly when the owner matches the identity' {
        $result = $script:items | Measure-OwnerAnomaly -Identity $script:actualOwner
        $result.AnomalyCount | Should -Be 0
        @($result.Anomalies).Count | Should -Be 0
    }

    #### - An identity that owns nothing makes every item an anomaly.
    It 'Reports every item when the identity does not match the owner' {
        $result = $script:items | Measure-OwnerAnomaly -Identity $script:foreignIdentity
        $result.AnomalyCount | Should -Be $script:items.Count
    }

    #### - `-ne` on strings is case insensitive in PowerShell, so a shouted identity
    ####   still matches. Anything that lowercases one side only would pass this too.
    It 'Compares the owner without regard to case' {
        $result = $script:items | Measure-OwnerAnomaly -Identity $script:actualOwner.ToUpper()
        $result.AnomalyCount | Should -Be 0
    }

    #### - `Anomalies` holds the offending items themselves, so the summary is
    ####   actionable rather than just a count.
    It 'Carries the offending AclItem objects in Anomalies' {
        $result = $script:items | Measure-OwnerAnomaly -Identity $script:foreignIdentity
        $anomalies = @($result.Anomalies)
        $anomalies[0].FullName | Should -Not -BeNullOrEmpty
        $anomalies[0].Owner | Should -Be $script:actualOwner
    }

    #### - `AclItems` retains the full input alongside the filtered set.
    It 'Retains every input in AclItems alongside the anomalies' {
        $result = $script:items | Measure-OwnerAnomaly -Identity $script:foreignIdentity
        @($result.AclItems).Count | Should -Be $script:items.Count
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">Measure-OwnerAnomaly elevated</h2>
####
#### Changing an owner needs elevation, so the one case that starts by doing that
#### is gated. The Administrators account name is resolved from its well known SID
#### rather than hardcoded, so it passes on a non English Windows install.
####
Describe 'Measure-OwnerAnomaly elevated' -Skip:(-not $IsElevatedHost) {
    BeforeAll {
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:dir | Out-Null
        $script:fileA = Join-Path $script:dir 'a.txt'
        $script:fileB = Join-Path $script:dir 'b.txt'
        Set-Content -LiteralPath $script:fileA -Value 'a' -NoNewline
        Set-Content -LiteralPath $script:fileB -Value 'b' -NoNewline
        $script:me = "$($env:USERDOMAIN)\$($env:USERNAME)"
        $script:administrators = ([Security.Principal.SecurityIdentifier]::new(
                [Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null
            )).Translate([Security.Principal.NTAccount]).Value
    }
    AfterAll {
        Remove-Item -LiteralPath $script:dir -Recurse -Force -ErrorAction SilentlyContinue
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - An item whose owner was changed out from under the current user is
    ####   reported as an anomaly, and the offending owner is named.
    It 'Flags an item owned by another principal' {
        $script:fileA | Get-AclItem | Set-AclItemOwner -Identity $script:administrators | Out-Null
        $result = @($script:fileA, $script:fileB) | Get-AclItem | Measure-OwnerAnomaly -Identity $script:me
        $result.AnomalyCount | Should -BeGreaterThan 0
        @($result.Anomalies).Owner | Should -Contain $script:administrators
    }
}
####
#### ---
####
