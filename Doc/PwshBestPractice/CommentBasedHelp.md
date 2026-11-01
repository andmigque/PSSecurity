# Comment Based Help

## Short description
> Describes how to write comment-based help content for functions and scripts.

## Long description

> You can write comment-based help content for functions and scripts by using special help comment keywords.
> The Get-Help cmdlet displays comment-based help in the same format in which it displays.
> Users can use all of the parameters of Get-Help, such as Detailed, Full, Examples, and Online.

To create Comment-based help content, you can use either style of comments: single-line comments or block comments.

The syntax for comment-based help is as follows:

```# .<help keyword>```
```# <help content>```

or

```powershell
<#
    .<help keyword>
    <help content>
#>
```

1. Comment-based help is written as a series of comments.
2. You can type a comment symbol # before each line of comments
3. Or you can use the <# and #> symbols to create a comment block.
4. All the lines within the comment block are interpreted as comments.
5. All of the lines in a comment-based help topic must be contiguous.
6. If a comment-based help topic follows a comment that's not part of the help topic
7. There must be at least one blank line between the last non-help comment line and the beginning of the comment-based help.
8. Keywords define each section of comment-based help. Each comment-based help keyword is preceded by a dot ..
9. The keywords can appear in any order. The keyword names aren't case-sensitive.

For example, the .DESCRIPTION keyword precedes a description of a function or script.

```powerShell
<#
.DESCRIPTION
Get-Function displays the name and syntax of all functions in the session.
#>
```

The comment block must contain at least one keyword. Some of the keywords, such as `.EXAMPLE`, can appear many times in the same comment block. The help content for each keyword begins on the line after the keyword and can span multiple lines.

## Syntax for comment-based help in functions

Comment-based help for a function can appear in one of three locations:

1. At the beginning of the function body.
2. At the end of the function body.
3. Before the `function` keyword. There can't be more than one blank line between the last line of the function help and the function keyword.

For example:

```powershell
function Get-Function {
    <#
        .<help keyword>
        <help content>
    #>

    # function logic
}
```

or

```powershell
function Get-Function {
    # function logic

    <#
        .<help keyword>
        <help content>
    #>
}
```

or

```powershell
<#
    .<help keyword>
    <help content>
#>
function Get-Function { }
```

## Syntax for comment-based help in scripts

Comment-based help for a script can appear in one of the following two locations in the script:

1. At the beginning of the script file. Script help can be preceded only by comments and blank lines.
2. At the end of the script file. However, if the script is signed, place comment-based help at the beginning of the file because the end is occupied by the signature block.

If the first item in the script body (after the help) is a function declaration, there must be at least two blank lines between the end of the script help and the function declaration. Otherwise, the help is interpreted as function help, not script help.

For example:

```powershell
<#
.<help keyword>
<help content>
#>
function Get-Function { }
```

or

```powershell
function Get-Function { }
<#
.<help keyword>
<help content>
#>
```

## Comment-based help keywords

The following are valid comment-based help keywords. These keywords can appear in any order in comment-based help, and they aren't case-sensitive.

### `.SYNOPSIS`
A brief description of the function or script. This keyword can be used only once in each topic.

### `.DESCRIPTION`
A detailed description of the function or script. This keyword can be used only once in each topic.

### `.PARAMETER`
The description of a parameter. Add a `.PARAMETER` keyword for each parameter in the function or script syntax.

Type the parameter name on the same line as the `.PARAMETER` keyword. Type the parameter description on the lines following the `.PARAMETER` keyword. PowerShell interprets all text between the `.PARAMETER` line and the next keyword (or the end of the comment block) as part of the parameter description.

Syntax:

```powershell
.PARAMETER <Parameter-Name>
```

The `.PARAMETER` keywords can appear in any order in the comment block, but function or script syntax determines the order in which parameter descriptions appear in the help topic.

You can also specify a parameter description by placing a comment in the function or script syntax immediately before the parameter variable name. For this to work, you must also have a comment block with at least one keyword.

If you use both a syntax comment and a `.PARAMETER` keyword, the `.PARAMETER` description is used, and the syntax comment is ignored.

```powershell
<#
.SYNOPSIS
    Short description here
#>
function Verb-Noun {
    [CmdletBinding()]
    param (
        # This is the same as .PARAMETER
        [string]$ComputerName
    )
    # Verb the Noun on the computer
}
```

### `.EXAMPLE`
A sample command that uses the function or script, optionally followed by sample output and a description. Repeat this keyword for each example.

### `.INPUTS`
The .NET types of objects that can be piped to the function or script. You can also include a description of the input objects. Repeat this keyword for each input type.

### `.OUTPUTS`
The .NET type of the objects that the cmdlet returns. You can also include a description of the returned objects. Repeat this keyword for each output type.

### `.NOTES`
Additional information about the function or script.

### `.LINK`
The name of a related topic. Repeat this keyword for each related topic. This content appears in the Related Links section of the help topic.

The `.LINK` content can include a URI to an online version of the same help topic. The online version opens when you use the `-Online` parameter of `Get-Help`. The URI must begin with `http` or `https`.

### `.COMPONENT`
The name of the technology or feature that the function or script uses (or to which it's related). The `-Component` parameter of `Get-Help` uses this value to filter search results.

### `.ROLE`
The name of the user role for the help topic. The `-Role` parameter of `Get-Help` uses this value to filter search results.

### `.FUNCTIONALITY`
Keywords that describe the intended use of the function. The `-Functionality` parameter of `Get-Help` uses this value to filter search results.

## Autogenerated content

The following content is automatically generated by `Get-Help`:

- Name
- Syntax
- Parameter list
- Parameter attribute table
- Common parameters
- Remarks

### Name
The Name section of function help is taken from the function name in syntax. The Name section for script help is taken from the script filename.

### Syntax
The Syntax section is generated from function or script syntax. To add detail (such as parameter types), add it to the syntax.

### Parameter list
The parameter list is generated from syntax and from descriptions provided by `.PARAMETER` keywords.

### Common parameters
Common parameters are added to syntax and parameter lists even if they have no effect.

### Parameter attribute table
`Get-Help` generates this table when you use `-Full` or `-Parameter`.

### Remarks
The Remarks section is generated from function or script name. You can't change it directly.

## Examples

### Comment-based help for a function

```powershell
function Add-Extension
{
param ([string]$Name,[string]$Extension = "txt")
$Name = $Name + "." + $Extension
$Name

<#
.SYNOPSIS

Adds a file name extension to a supplied name.

.DESCRIPTION

Adds a file name extension to a supplied name.
Takes any strings for the file name or extension.

.PARAMETER Name
Specifies the file name.

.PARAMETER Extension
Specifies the extension. "Txt" is the default.

.INPUTS

None. You can't pipe objects to Add-Extension.

.OUTPUTS

System.String. Add-Extension returns a string with the extension
or file name.

.EXAMPLE

PS> Add-Extension -Name "File"
File.txt

.EXAMPLE

PS> Add-Extension -Name "File" -Extension "doc"
File.doc

.EXAMPLE

PS> Add-Extension "File" "doc"
File.doc

.LINK

http://www.fabrikam.com/extension.html

.LINK

Set-Item
#>
}
```

Result:

```powershell
Get-Help -Name "Add-Extension" -Full
```

### Parameter descriptions in function syntax

```powershell
    function Add-Extension
    {
        param
        (
            [string]
            # Specifies the file name.
            $Name,
            [string]
            # Specifies the file name extension. "Txt" is the default.
            $Extension = "txt"
        )

        <#
            .SYNOPSIS

                Adds a file name extension to a supplied name.

            .DESCRIPTION

                Adds a file name extension to a supplied name. Takes any strings for the
                file name or extension.

            .INPUTS

                None. You can't pipe objects to Add-Extension.

            .OUTPUTS

                System.String. Add-Extension returns a string with the extension or
                file name.

            .EXAMPLE

                PS> Add-Extension -Name "File"
                File.txt

            .EXAMPLE

                PS> Add-Extension -Name "File" -Extension "doc"
                File.doc

            .EXAMPLE

                PS> Add-Extension "File" "doc"
                File.doc

            .LINK

                http://www.fabrikam.com/extension.html
        #>

        $Name = $Name + "." + $Extension
        $Name
    }
```

### Comment-based help for a script

```powershell
<#
.SYNOPSIS

Performs monthly data updates.

.DESCRIPTION

The Update-Month.ps1 script updates the registry with new data generated
during the past month and generates a report.

.PARAMETER InputPath
Specifies the path to the CSV-based input file.

.PARAMETER OutputPath
Specifies the name and path for the CSV-based output file. By default,
MonthlyUpdates.ps1 generates a name from the date and time it runs, and
saves the output in the local directory.

.INPUTS

None. You can't pipe objects to Update-Month.ps1.

.OUTPUTS

None. Update-Month.ps1 doesn't generate any output.

.EXAMPLE

PS> .\Update-Month.ps1

.EXAMPLE

PS> .\Update-Month.ps1 -InputPath C:\Data\January.csv

.EXAMPLE

PS> .\Update-Month.ps1 -InputPath C:\Data\January.csv -OutputPath `
C:\Reports\2009\January.csv
#>

param ([string]$InputPath, [string]$OutputPath)

function Get-Data { }
...
```

If the script isn't in a directory listed in `$Env:PATH`, include the script path:

```powershell
Get-Help -Name .\update-month.ps1 -Full
```

### Usage:

```powershell
Get-Help -Name help
```
