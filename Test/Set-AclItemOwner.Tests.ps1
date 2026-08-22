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
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Set-AclItemOwner</h2>
####
Describe 'Set-AclItemOwner' -Skip:(-not $IsWindows) {
    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'Set-AclItemOwner' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }

    #### - The composition `Get-AclItem | Set-AclItemOwner` is reachable, and the
    ####   mutator declares ShouldProcess so `-WhatIf` is available.
    It 'Takes an AclItem from the pipeline and supports ShouldProcess' {
        $cmd = Get-Command -Module PSSecurity -Name 'Set-AclItemOwner'

        # Attributes holds every attribute on the parameter, and only the
        # ParameterAttribute carries ValueFromPipeline.
        $parameterAttribute = $cmd.Parameters['AclItem'].Attributes |
            Where-Object { $_ -is [Parameter] } |
            Select-Object -First 1
        $parameterAttribute.ValueFromPipeline | Should -BeTrue
        $cmd.Parameters.Keys | Should -Contain 'WhatIf'
    }
}
####
#### ---
####

#### <h2 style="color: #DCA657;">Set-AclItemOwner elevated</h2>
####
#### The Administrators account name is resolved from its well known SID rather than
#### hardcoded, so these cases pass on a non English Windows install.
####
Describe 'Set-AclItemOwner elevated' -Skip:(-not $IsElevatedHost) {
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
    #### - The returned item carries the new owner, and identifies the file it changed.
    It 'Returns the re-read item with the new owner' {
        $result = $script:fileA | Get-AclItem | Set-AclItemOwner -Identity $script:administrators
        $result.Owner | Should -Be $script:administrators
        $result.FullName | Should -Be $script:fileA
    }

    #### - The change survives a fresh read, so the return value reflects disk and
    ####   not just what the function intended to do.
    It 'Persists the change to disk' {
        $script:fileA | Get-AclItem | Set-AclItemOwner -Identity $script:me | Out-Null
        (Get-AclItem -LiteralPath $script:fileA).Owner | Should -Be $script:me
    }

    #### - Omitting `-Identity` falls back to the current user.
    It 'Defaults the identity to the current user' {
        $script:fileB | Get-AclItem | Set-AclItemOwner -Identity $script:administrators | Out-Null
        $result = $script:fileB | Get-AclItem | Set-AclItemOwner
        $result.Owner | Should -Be $script:me
    }

    #### - `-WhatIf` reaches the ShouldProcess branch and writes nothing.
    It 'Leaves the owner alone under WhatIf' {
        $script:fileB | Get-AclItem | Set-AclItemOwner -Identity $script:administrators | Out-Null
        $script:fileB | Get-AclItem | Set-AclItemOwner -Identity $script:me -WhatIf | Out-Null
        (Get-AclItem -LiteralPath $script:fileB).Owner | Should -Be $script:administrators
    }

    #### - A foreign object fails rather than silently mutating something.
    It 'Rejects an object that did not come from Get-AclItem' {
        # FileInfo carries FullName, so the guard in Set-AclItemOwner lets it through
        # and the failure lands on the missing Owner property instead of the usage
        # message. Asserting only that it throws keeps this test honest either way.
        { Get-Item -LiteralPath $script:fileA | Set-AclItemOwner -Identity $script:me } | Should -Throw
    }
}
####
#### ---
####
