#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Add-TypeDirectoryEnumerator {
    <#
    .SYNOPSIS
        Loads the PSSecurity.DirectoryEnumerator type.

    .DESCRIPTION
        Compiles the embedded C# definition if the type is absent.
        DirectoryEnumerator enumerates immediate child directories or all
        descendant directories, with optional name exclusions. It can return a
        list of directories or stream entries classified by directory type.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        # Run from module scope.
        Add-TypeDirectoryEnumerator
        $root = Get-Item -LiteralPath . -ErrorAction Stop
        # Pass $true to enumerate descendants.
        $enumerator = [PSSecurity.DirectoryEnumerator]::new($true)
        # Exclude every .git directory and its descendants.
        $exclude = [System.Collections.Generic.HashSet[string]]::new(
            [string[]]@('.git'),
            [System.StringComparer]::OrdinalIgnoreCase
        )
        $enumerator.EnumerateItem($root, $exclude)
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param()

    if ('PSSecurity.DirectoryEnumerator' -as [type]) {
        return
    }

    Add-Type -ErrorAction Stop -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace PSSecurity;

public class DirectoryEnumerator
{
    private readonly bool recurse;
    private readonly EnumerationOptions enumerationOptions;

    public DirectoryEnumerator(bool recurse)
    {
        this.recurse = recurse;
        this.enumerationOptions = new EnumerationOptions
        {
            RecurseSubdirectories = false,
            IgnoreInaccessible = true,
            AttributesToSkip = FileAttributes.ReparsePoint,
            ReturnSpecialDirectories = false
        };
    }

    public IEnumerable<DirectoryInfo> EnumerateItem(
        DirectoryInfo dir,
        HashSet<string> excludeSet)
    {
        var excludePatterns = excludeSet.Select(this.ConvertWildcardToRegex).ToArray();

        // The stack controls recursion so excluded directories are skipped before opening them.
        var directories = new List<DirectoryInfo>();
        var pending = new Stack<DirectoryInfo>();
        pending.Push(dir);

        while (pending.Count > 0)
        {
            var current = pending.Pop();
            foreach (var subDir in this.SafeEnumerateDirectories(current))
            {
                if (excludePatterns.Any(pattern => pattern.IsMatch(subDir.Name)))
                    continue;

                directories.Add(subDir);
                if (this.recurse)
                    pending.Push(subDir);
            }
        }

        return directories;
    }

    public IEnumerable<DirectoryInfo> SafeEnumerateDirectories(DirectoryInfo dir)
        => this.SafeEnumerate(() => dir.EnumerateDirectories("*", this.enumerationOptions));

    public IEnumerable<T> SafeEnumerate<T>(Func<IEnumerable<T>> enumerate)
    {
        IEnumerable<T> items;
        try
        {
            items = enumerate();
        }
        catch (Exception ex) when (this.IsEnumerationException(ex))
        {
            yield break;
        }

        using var enumerator = items.GetEnumerator();
        while (true)
        {
            T current;
            try
            {
                if (!enumerator.MoveNext())
                    break;

                current = enumerator.Current;
            }
            catch (Exception ex) when (this.IsEnumerationException(ex))
            {
                yield break;
            }

            yield return current;
        }
    }

    public bool IsEnumerationException(Exception ex)
        => ex is UnauthorizedAccessException
            || ex is DirectoryNotFoundException
            || ex is IOException
            || ex is PathTooLongException;

    public Regex ConvertWildcardToRegex(string pattern)
    {
        var regexPattern = "^" + Regex.Escape(pattern)
            .Replace("\\*", ".*")
            .Replace("\\?", ".")
            + "$";

        return new Regex(regexPattern, RegexOptions.IgnoreCase | RegexOptions.Compiled);
    }

    public sealed class DirectoryItem
    {
        public DirectoryInfo Item { get; }
        public string ItemType { get; }

        public DirectoryItem(DirectoryInfo item, string itemType)
        {
            Item = item;
            ItemType = itemType;
        }
    }

    public IEnumerable<DirectoryItem> StreamDirectoryItems(
        FileSystemInfo root,
        HashSet<string> excludeSet,
        Func<DirectoryInfo, string> getLinkType)
    {
        if (root is not DirectoryInfo rootDirectory ||
            (rootDirectory.Attributes & FileAttributes.ReparsePoint) != 0)
        {
            throw new ArgumentException(
                "LiteralPath must identify an ordinary filesystem directory.",
                nameof(root));
        }

        var excludePatterns = excludeSet.Select(this.ConvertWildcardToRegex).ToArray();
        var options = new EnumerationOptions
        {
            RecurseSubdirectories = false,
            IgnoreInaccessible = true,
            AttributesToSkip = 0,
            ReturnSpecialDirectories = false
        };

        var pending = new Stack<DirectoryInfo>();
        pending.Push(rootDirectory);

        while (pending.Count > 0)
        {
            var current = pending.Pop();
            foreach (var directory in this.SafeEnumerate(
                () => current.EnumerateDirectories("*", options)))
            {
                if (excludePatterns.Any(pattern => pattern.IsMatch(directory.Name)))
                    continue;

                var isReparsePoint =
                    (directory.Attributes & FileAttributes.ReparsePoint) != 0;

                var itemType = isReparsePoint
                    ? getLinkType(directory) switch
                    {
                        "SymbolicLink" => "SymbolicLink",
                        "Junction" => "Junction",
                        _ => "OtherReparsePoint"
                    }
                    : "Directory";

                yield return new DirectoryItem(directory, itemType);

                if (this.recurse && !isReparsePoint)
                    pending.Push(directory);
            }
        }
    }
}
'@
}
