Set-StrictMode -Version Latest

function Get-AclItem {
    <#
    .SYNOPSIS
        Gets ownership, access rules, and metadata for an item.

    .PARAMETER LiteralPath
        Existing item path, treated literally. Accepts paths from the pipeline.

    .EXAMPLE
        Get-AclItem -LiteralPath C:\Data

        Returns the item metadata and ACL details.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline,
            HelpMessage = 'Existing item path, treated literally. Accepts paths from the pipeline.')]
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

