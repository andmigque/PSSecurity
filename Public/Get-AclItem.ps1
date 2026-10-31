#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

if ($IsWindows) {
    function Get-AclItem {
        <#
        .SYNOPSIS
            Gets ownership, access rules, and metadata for an item.

        .DESCRIPTION
            Reads the security descriptor of an item with Get-Acl and combines it with the
            item's file system metadata into one object. Hidden and system items are
            included. Audit rules (SACL) are not returned. Windows only.

        .PARAMETER LiteralPath
            The path of an existing item. The path is used exactly as typed, so wildcard
            characters such as [ and ] are not expanded. Accepts paths from the pipeline.

        .INPUTS
            System.String. You can pipe item paths to this function.

        .OUTPUTS
            System.Management.Automation.PSCustomObject. One object per item with the
            owner, group, access rules, SDDL, timestamps, and attributes.

        .EXAMPLE
            Get-AclItem -LiteralPath C:\Data

            Returns the item metadata and ACL details for C:\Data.

        .EXAMPLE
            'C:\Data', 'C:\Logs[2026]' | Get-AclItem

            Returns the ACL details for each piped path. The brackets are read literally.

        .EXAMPLE
            (Get-AclItem -LiteralPath C:\Data).Access | Where-Object -Property IsInherited -EQ $false

            Lists only the explicit, non-inherited access rules on C:\Data.
        #>
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory, ValueFromPipeline,
                HelpMessage = 'Existing item path, treated literally. Accepts path from the pipeline.')]
            [ValidateNotNullOrEmpty()]
            [string]$LiteralPath
        )
        process {
            if (-not (Test-Path -LiteralPath $LiteralPath)) {
                throw "Get-AclItem can not find literal path: $LiteralPath"
            }
            $acl = Get-Acl -LiteralPath $LiteralPath

            # Force is required. Test-Path and Get-Acl both see hidden and system items,
            # Get-Item does not, so the guard above would pass and this line would fail.
            $item = Get-Item -LiteralPath $LiteralPath -Force

            [PSCustomObject]@{
                FullName                = $item.FullName
                Name                    = $item.Name
                Path                    = $acl.Path
                ItemType                = $item.GetType().Name
                Owner                   = $acl.Owner
                Group                   = $acl.Group
                Access                  = $acl.Access | ForEach-Object {
                    [PSCustomObject]@{
                        FileSystemRights  = $_.FileSystemRights
                        AccessControlType = $_.AccessControlType
                        IdentityReference = $_.IdentityReference
                        IsInherited       = $_.IsInherited
                        InheritanceFlags  = $_.InheritanceFlags
                        PropagationFlags  = $_.PropagationFlags
                    }
                }
                CreationTime            = $item.CreationTime
                LastAccessTime          = $item.LastAccessTime
                LastWriteTime           = $item.LastWriteTime
                Mode                    = $item.Mode
                Attributes              = $item.Attributes
                Security                = $acl.Sddl
                AreAccessRulesCanonical = $acl.AreAccessRulesCanonical
                AreAuditRulesCanonical  = $acl.AreAuditRulesCanonical
                AreAccessRulesProtected = $acl.AreAccessRulesProtected
                AreAuditRulesProtected  = $acl.AreAuditRulesProtected
            }
            # TODO: expose $acl.Audit. Reading it needs SeSecurityPrivilege, which
            # elevation alone does not grant, so it wants its own -Audit switch.
        }
    }
}