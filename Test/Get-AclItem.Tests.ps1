using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

BeforeAll {
    $moduleRoot = Split-Path -Path $PSScriptRoot -Parent
    Import-Module (Join-Path -Path $moduleRoot -ChildPath 'PSSecurity.psm1') -Force
}
AfterAll {
    Remove-Module PSSecurity -Force -ErrorAction SilentlyContinue
}

#### <h2 style="color: #DCA657;">Get-AclItem</h2>
####
#### The fixture builds three files that each broke this function at some point:
#### an ordinary file, a name containing wildcard characters, and a hidden item.
####
Describe 'Get-AclItem' -Skip:(-not $IsWindows) {
    BeforeAll {
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:dir | Out-Null
        $script:file = Join-Path $script:dir 'a.txt'
        Set-Content -LiteralPath $script:file -Value 'a' -NoNewline

        # Square brackets are wildcard syntax. The function promises literal handling.
        $script:wildcardFile = Join-Path $script:dir 'b[1].txt'
        Set-Content -LiteralPath $script:wildcardFile -Value 'b' -NoNewline

        $script:hiddenFile = Join-Path $script:dir 'desktop.ini'
        Set-Content -LiteralPath $script:hiddenFile -Value 'x' -NoNewline
        (Get-Item -LiteralPath $script:hiddenFile -Force).Attributes = 'Hidden'

        $script:expectedFields = @(
            'FullName', 'Name', 'Path', 'ItemType', 'Owner', 'Group', 'Access',
            'CreationTime', 'LastAccessTime', 'LastWriteTime', 'Mode', 'Attributes', 'Security',
            'AreAccessRulesCanonical', 'AreAuditRulesCanonical',
            'AreAccessRulesProtected', 'AreAuditRulesProtected'
        )
    }
    AfterAll {
        Remove-Item -LiteralPath $script:dir -Recurse -Force -ErrorAction SilentlyContinue
    }

    ####
    #### <b style="color: #D2A8FF;">Cases</b>
    ####
    #### - The function is exported, and is a function rather than an alias.
    It 'Is exported as a function' {
        $cmd = Get-Command -Module PSSecurity -Name 'Get-AclItem' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }

    #### - A file returns every documented field.
    It 'Returns the documented field set for a file' {
        $item = Get-AclItem -LiteralPath $script:file
        $names = @($item.PSObject.Properties.Name)
        foreach ($field in $script:expectedFields) {
            $names | Should -Contain $field
        }
    }

    #### - A directory returns the same field set. One shape for both types is the
    ####   whole point, and this is the case that catches a FileInfo-only property.
    It 'Returns the same field set for a directory' {
        # Regression: Length and IsReadOnly are FileInfo-only and threw on directories.
        $item = Get-AclItem -LiteralPath $script:dir
        $names = @($item.PSObject.Properties.Name)
        foreach ($field in $script:expectedFields) {
            $names | Should -Contain $field
        }
    }

    #### - `ItemType` distinguishes the two without the caller testing types.
    It 'Reports ItemType as the underlying type name' {
        (Get-AclItem -LiteralPath $script:file).ItemType | Should -Be 'FileInfo'
        (Get-AclItem -LiteralPath $script:dir).ItemType | Should -Be 'DirectoryInfo'
    }

    #### - Each nested access entry carries its documented fields.
    It 'Projects each ACE with the documented fields' {
        $access = @((Get-AclItem -LiteralPath $script:file).Access)
        $access.Count | Should -BeGreaterThan 0
        $aceFields = @($access[0].PSObject.Properties.Name)
        foreach ($field in @('FileSystemRights', 'AccessControlType', 'IdentityReference',
                'IsInherited', 'InheritanceFlags', 'PropagationFlags')) {
            $aceFields | Should -Contain $field
        }
    }

    #### - A missing path throws the function's own message, not a provider error.
    It 'Throws a named error when the path does not exist' {
        $missing = Join-Path $script:dir 'no-such-file.txt'
        { Get-AclItem -LiteralPath $missing } | Should -Throw '*can not find literal path*'
    }

    #### - Regression: `-Path` treats `b[1].txt` as a character class. A pattern
    ####   matching two files returns two items and silently corrupts the result.
    It 'Treats wildcard characters in the path literally' {
        (Get-AclItem -LiteralPath $script:wildcardFile).Name | Should -Be 'b[1].txt'
    }

    #### - Binding from the pipeline resolves to the same absolute path.
    It 'Accepts the path from the pipeline' {
        ($script:file | Get-AclItem).FullName | Should -Be $script:file
    }

    #### - Regression: hidden items are the ones an ownership audit most wants.
    It 'Reads a hidden item' {
        # Get-ChildItem -Force is the normal way to feed this function, so hidden
        # items reach it in any real tree. Get-Item needs -Force to return them.
        (Get-AclItem -LiteralPath $script:hiddenFile).Name | Should -Be 'desktop.ini'
    }
}
####
#### ---
####
