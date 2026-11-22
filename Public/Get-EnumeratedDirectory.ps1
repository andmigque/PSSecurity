#!/usr/bin/env pwsh
Set-StrictMode -Version Latest

function Add-TypeDirectoryEnumerator {
    <#
    .SYNOPSIS
        Loads the directory enumerator used by Get-EnumeratedDirectory.

    .DESCRIPTION
        Compiles the embedded C# type the first time the session needs it.

    .INPUTS
        None.

    .OUTPUTS
        None.

    .EXAMPLE
        Add-TypeDirectoryEnumerator

        Makes the enumerator available in the current session.
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
}
'@
}

function Get-EnumeratedDirectory {
    <#
    .SYNOPSIS
        Lists the child directories of a filesystem path.

    .DESCRIPTION
        Returns immediate child directories by default. With -Recurse, a matching
        exclusion skips the entire subtree. The walk includes hidden directories,
        skips reparse points such as symbolic links, and skips unreadable contents.

    .PARAMETER LiteralPath
        Directory to enumerate. The path is used exactly as typed, including brackets.
        Defaults to the current location. Accepts directory paths from the pipeline.

    .PARAMETER Exclude
        Case-insensitive patterns matched against each directory name. Use * for
        any number of characters and ? for one character. Brackets are literal.

    .PARAMETER Recurse
        Searches all descendants of the starting directory.

    .INPUTS
        System.String. You can pipe directory paths to this function.

    .OUTPUTS
        System.Collections.Generic.List[System.IO.DirectoryInfo]. One list per
        input path. A directory with no matching children produces an empty list.

    .EXAMPLE
        Get-EnumeratedDirectory

        Lists the immediate child directories of the current location.

    .EXAMPLE
        Get-EnumeratedDirectory -LiteralPath . -Recurse -Exclude '.git', 'bin*'

        Lists descendants and skips subtrees named .git or starting with bin.

    .EXAMPLE
        './Public', './Private' | Get-EnumeratedDirectory -Recurse

        Returns a separate list of descendants for each input path.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[System.IO.DirectoryInfo]])]
    param(
        [Parameter(ValueFromPipeline, HelpMessage = 'Enter a literal directory path. Accepts paths from the pipeline.')]
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath = $PWD.Path,

        [Parameter(HelpMessage = 'Enter directory name patterns to skip, such as .git or bin*.')]
        [ValidateNotNull()]
        [string[]]$Exclude = @(),

        [Parameter(HelpMessage = 'Also enumerate descendant directories.')]
        [switch]$Recurse
    )
    begin {
        Add-TypeDirectoryEnumerator
        $enumerator = [PSSecurity.DirectoryEnumerator]::new($Recurse.IsPresent)
        $excludeSet = [System.Collections.Generic.HashSet[string]]::new(
            $Exclude,
            [System.StringComparer]::OrdinalIgnoreCase
        )
    }
    process {
        $directory = Get-Item -LiteralPath $LiteralPath -Force -ErrorAction Stop
        Write-Output -NoEnumerate -InputObject ($enumerator.EnumerateItem($directory, $excludeSet))
    }
}
