function Add-TypeDirectoryEnumerator {
    if (-not ('PSSecurity.DirectoryEnumerator' -as [type])) {
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

        // Discover all non-excluded directories first to avoid early file errors
        // preventing deeper traversal.
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
}

function Get-EnumeratedDirectory {
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string]$LiteralPath = (Get-Location).Path,

        [ValidateNotNull()]
        [string[]]$Exclude = @(),

        [switch]$Recurse
    )

    $directory = Get-Item -LiteralPath $LiteralPath -Force -ErrorAction Stop
    $excludeSet = [System.Collections.Generic.HashSet[string]]::new(
        $Exclude,
        [System.StringComparer]::OrdinalIgnoreCase
    )

    Add-TypeDirectoryEnumerator
    $enumerator = [PSSecurity.DirectoryEnumerator]::new($Recurse.IsPresent)
    ,($enumerator.EnumerateItem($directory, $excludeSet))
}
