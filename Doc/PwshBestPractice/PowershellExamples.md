### Changing location to Alias: drive

```powershell
Set-Location Alias:
```

### Returning to a file system drive

```powershell
Set-Location C:
```

### Displaying contents of Alias: drive

```powershell
PS Alias:\> Get-Item -Path *
```

### Alternate way to display contents of Alias: drive

```powershell
Get-ChildItem -Path Alias:
```

### Get a selected alias (`ls`)

```powershell
Get-Item -Path Alias:ls
```

### Retrieve definition for an alias using dollar sign prefix

```powershell
$Alias:ls
```

### Get all aliases for Get-ChildItem cmdlet

```powershell
Get-Item -Path Alias:* | Where-Object {$_.Definition -eq "Get-ChildItem"}
```

### Create an alias from the Alias: drive

```powershell
PS Alias:\> New-Item -Path . -Name serv -Value Get-Service -Options "AllScope"
```

### Create an alias with an absolute path (Notepad.exe)

```powershell
New-Item -Path Alias:np -Value C:\windows\notepad.exe
```

### Create an alias to a new function (`CD32`)

```powershell
function CD32 {Set-Location -Path C:\windows\system32}
Set-Item -Path Alias:go -Value CD32
```

### Change the options of an alias (`dir`)

```powershell
Set-Item -Path Alias:dir -Options "AllScope, ReadOnly"
```

### Change an alias's referenced command (`gp`)

```powershell
Set-Item -Path gp -Value Get-Process -Force
```

### View the effect of changing an alias

```powershell
Get-Item -Path gp | Format-List -Property *
```

### Rename an alias (`popd` to `pop`)

```powershell
Rename-Item -Path Alias:popd -NewName pop
```

### Copying an alias (`pushd` to `push`)

```powershell
Copy-Item -Path Alias:pushd -Destination Alias:push
```

### Deleting an alias (`serv`)

```powershell
Remove-Item -Path Alias:serv
```

### Deleting aliases that begin with 's' (excluding read-only)

```powershell
Clear-Item -Path Alias:s*
```

### Deleting read-only aliases

```powershell
Remove-Item Alias:* -Force
```

### Get customized help topics for Get-ChildItem

```powershell
Get-Help Get-ChildItem
```

### Get customized help topics for Alias: drive

```powershell
Get-Help Get-ChildItem -Path Alias:
```
### Creating a 'gas' alias for Get-AuthenticodeSignature

```powershell
New-Alias -Name gas -Value Get-AuthenticodeSignature
```

### Using the 'gas' alias to get Authenticode signature

```powershell
Get-AuthenticodeSignature SqlScript.ps1
```

### Alternate way to use the 'gas' alias

```powershell
gas SqlScript.ps1
```

### Aliasing an executable

```powershell
"C:\Program Files\Microsoft Office\Office11\Winword.exe"
```

### Getting all aliases in the current session

```powershell
Get-Alias
```

### Getting detailed help for a cmdlet

```powershell
Get-Help <cmdlet-Name> -Detailed
```

### Getting detailed help for Export-Alias

```powershell
Get-Help Export-Alias -Detailed
```

### Creating a 'gh' alias for Get-Help

```powershell
New-Alias -Name gh -Value Get-Help
```

### Using the 'gh' alias for detailed help

```powershell
Get-Help Get-CimInstance -Detailed
```

### Alternate way to use the 'gh' alias

```powershell
gh Get-CimInstance -Detailed
```

### Getting all aliases

```powershell
Get-Alias
```

### Getting aliases that begin with 'p'

```powershell
Get-Alias -Name p*
```

### Getting aliases for Get-ChildItem

```powershell
Get-Alias -Definition Get-ChildItem
```

### Get-Alias output format for non-hyphenated alias

```powershell
Get-Alias ac

CommandType     Name                    Version    Source
-----------     ----                    -------    ------
Alias           ac -> Add-Content
```

### Creating a function for Get-Eventlog -LogName System

```powershell
function Get-SystemEventlog {Get-Eventlog -LogName System}
Set-Alias -Name syslog -Value Get-SystemEventlog
```

### Viewing properties and methods of alias objects

```powershell
Get-Alias | Get-Member
```

### Viewing all properties of the 'dir' alias

```powershell
Get-Alias -Name dir | Format-List -Property *
```

### Entering the Alias: drive

```powershell
Set-Location Alias:
```

### Viewing contents of Alias: drive

```powershell
Get-ChildItem
```

### Viewing contents of Alias: drive from another drive

```powershell
Get-ChildItem -Path Alias:
```

### Getting aliases that begin with 'p' from Alias: drive

```powershell
Get-ChildItem -Path Alias:p*
```

### Getting help for Alias provider

```powershell
Get-Help Alias
```
### Using $PSStyle to create decorated strings

```powershell
"$($PSStyle.Background.BrightCyan)Power$($PSStyle.Underline)$($PSStyle.Bold)Shell$($PSStyle.Reset)"
```

### Setting background color to 24-bit Beige (RGB)

```powershell
$PSStyle.Background.FromRgb(245, 245, 220)
```

### Setting background color to 24-bit Beige (hex)

```powershell
$PSStyle.Background.FromRgb(0xf5f5dc)
```

### Setting the rendering style to a minimal progress bar

```powershell
$PSStyle.Progress.View = 'Minimal'
```

### Redirecting Get-ChildItem output to a file (bash process)

```powershell
pwsh -NoProfile -Command 'Get-ChildItem' > out.txt
```

### Redirecting Get-ChildItem output to a file (PowerShell session)

```powershell
pwsh -NoProfile -Command 'Get-ChildItem > out.txt'
```

### Getting static methods of the PSStyle class

```powershell
[System.Management.Automation.PSStyle] | Get-Member -Static -MemberType Method
```

### Mapping background color to escape sequence

```powershell
using namespace System.Management.Automation
[PSStyle]::MapBackgroundColorToEscapeSequence('Black') | Format-Hex

   Label: String (System.String) <3A04954D>

          Offset Bytes                                           Ascii
                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
          ------ ----------------------------------------------- -----
0000000000000000 1B 5B 34 30 6D                                  ?[40m
```

### Mapping foreground color to escape sequence

```powershell
[PSStyle]::MapForegroundColorToEscapeSequence('Red') | Format-Hex

   Label: String (System.String) <38B50F41>

          Offset Bytes                                           Ascii
                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
          ------ ----------------------------------------------- -----
0000000000000000 1B 5B 39 31 6D                                  ?[91m
```

### Mapping color pair to escape sequence

```powershell
[PSStyle]::MapColorPairToEscapeSequence('Red','Black') | Format-Hex

   Label: String (System.String) <365A5875>

          Offset Bytes                                           Ascii
                 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
          ------ ----------------------------------------------- -----
0000000000000000 1B 5B 39 31 3B 34 30 6D                         ?[91;40m
```
### Addition operator with numbers, strings, and arrays

```powershell
6 + 2                        # result = 8
"file" + "name"              # result = "filename"
@(1, "one") + @(2.0, "two")  # result = @(1, "one", 2.0, "two")
@{"one" = 1} + @{"two" = 2}  # result = @{"one" = 1; "two" = 2}
```

### Subtraction operator with numbers and Get-Date

```powershell
6 - 2   # result = 4
- -6    # result = 6
(Get-Date).AddDays(-1) # Yesterday's date
```

### Multiplication operator with numbers, arrays, and strings

```powershell
6 * 2       # result = 12
@("!") * 4  # result = @("!","!","!","!")
"!" * 3     # result = "!!!"
```

### Division operator

```powershell
6 / 2  # result = 3
```

### Modulus operator

```powershell
7 % 2  # result = 1
```

### Bitwise AND operator

```powershell
5 -band 3  # result = 1
```

### Bitwise NOT operator

```powershell
-bnot 5  # result = -6
```

### Bitwise OR operator

```powershell
5 -bor 0x03  # result = 7
```

### Bitwise XOR operator

```powershell
5 -bxor 3   # result = 6
```

### Shift-left operator

```powershell
102 -shl 2  # result = 408
```

### Shift-right operator

```powershell
102 -shr 2  # result = 25
```

### Operator precedence examples

```powershell
3+6/3*4    # result = 11
3+6/(3*4)  # result = 3.5
(3+6)/3*4  # result = 12
```

### Complicated assignment statement illustrating operator precedence

```powershell
$a = 0
$b = @(1,2)
$c = @(-1,-2)

$b[$a] = $c[$a++]
```

### Equivalent code for the complicated assignment statement

```powershell
$a = 0
$b = @(1,2)
$c = @(-1,-2)

$tmp = $c[$a]
$a = $a + 1
$b[$a] = $tmp
```

### Rounding down with integer division

```powershell
[int]( 5 / 2 )  # Result is rounded down
2
```

### Rounding up with integer division

```powershell
[int]( 7 / 2 )  # Result is rounded up
4
```

### Rounding using [Math]::Round with AwayFromZero

```powershell
[int][Math]::Round(5 / 2,[MidpointRounding]::AwayFromZero)
3
```

### Rounding using [Math]::Ceiling

```powershell
[int][Math]::Ceiling(5 / 2)
3
```

### Rounding using [Math]::Floor

```powershell
[int][Math]::Floor(5 / 2)
2
```

### Type conversion to accommodate result (Int32 to Double)

```powershell
2 + 3.1
(2).GetType().FullName
(2 + 3.1).GetType().FullName

5.1
System.Int32
System.Double
```

### Type widening for large results (Int32 to Double)

```powershell
(512MB).GetType().FullName
(512MB * 512MB).GetType().FullName

System.Int32
System.Double
```

### Type widening for mixed types (Int32, UInt32 to Int64)

```powershell
([int32]::MinValue + [uint32]::MaxValue).GetType().FullName

System.Int64
```

### MaxValue + 1 for [decimal] (throws exception)

```powershell
[decimal]::MaxValue
79228162514264337593543950335

[decimal]::MaxValue + 1
RuntimeException: Value was either too large or too small for a Decimal.
```

### Loss of precision with large [long] and [int] (results in Double)

```powershell
(9223372036854775807 + 2).GetType().FullName
System.Double
```

### Casting to [ulong] yields inaccurate result due to double conversion

```powershell
[ulong](9223372036854775807 + 2)
9223372036854775808
```

### Correct result with [ulong] literal

```powershell
9223372036854775807ul + 2
9223372036854775809
```

### Exceeding [ulong] range (results in Double)

```powershell
([ulong]::MaxValue + 1).GetType().FullName
System.Double
```

### Bigint division truncates non-integer values

```powershell
[bigint]1 / 1.9
1
1 / [bigint]1.9
1
```

### Int divided by Double (no truncation)

```powershell
1 / 1.9
0.526315789473684
1 / [int]1.9
0.5
```

### Concatenating arrays

```powershell
$a = 1,2,3
$b = "A","B","C"
$a + $b

1
2
3
A
B
C
```

### Arithmetic operations with different object types

```powershell
$array = 1,2,3
$red = [ConsoleColor]::Red
$blue = [ConsoleColor]::Blue

"file" + 16      # result = "file16"
$array + 16      # result = 1,2,3,16
$array + "file"  # result = 1,2,3,"file"
$array * 2       # result = 1,2,3,1,2,3
"file" * 3       # result = "filefilefile"
$blue + 3        # result = Red
$red - 3         # result = Blue
$blue - $red     # result = -3
+ '123'          # result = 123
```

### Non-commutative nature of addition (string first)

```powershell
PS> "file" + 16
file16
```

### Non-commutative nature of addition (number first, throws error)

```powershell
PS> 16 + "file"
InvalidArgument: can't convert value "file" to type "System.Int32". Error:
"Input string wasn't in a correct format."
```

### Adding hash tables with unique keys

```powershell
$hash1 = @{a=1; b=2; c=3}
$hash2 = @{c1="Server01"; c2="Server02"}
$hash1 + $hash2

Name                           Value
----                           -----
c2                             Server02
a                              1
b                              2
c1                             Server01
c                              3
```

### Adding hash tables with duplicate keys (throws error)

```powershell
$hash1 = @{a=1; b=2; c=3}
$hash2 = @{c1="Server01"; c="Server02"}
$hash1 + $hash2

OperationStopped:
Line |
   3 |  $hash1 + $hash2
         |  ~~~~~~~~~~~~~~~
         | Item has already been added. Key in dictionary: 'c'  Key being added: 'c'
```

### Adding a hash table to an array

```powershell
$array1 = @(0, "Hello World", [datetime]::Now)
$hash1 = @{a=1; b=2}
$array2 = $array1 + $hash1
$array2

0
Hello World

Monday, June 12, 2017 3:05:46 PM

Key   : a
Value : 1
Name  : a

Key   : b
Value : 2
Name  : b
```

### Cannot add other types to a hash table (throws error)

```powershell
$hash1 + 2

InvalidOperation: A hash table can only be added to another hash table.
```

### Using += assignment operator to add items to an array

```powershell
$array = @()
(0..2).ForEach{ $array += $_ }
$array

0
1
2
```

### Arithmetic operators with variables (numbers)

```powershell
PS> $intA = 6
PS> $intB = 4
PS> $intA + $intB
10
```

### Arithmetic operators with variables (strings)

```powershell
PS> $a = "Power"
PS> $b = "Shell"
PS> $a + $b
PowerShell
```

### Arithmetic operators with commands (Get-Date and New-TimeSpan)

```powershell
(Get-Date) + (New-TimeSpan -Day 1)
```

### Arithmetic operators with command properties (Where-Object and Process.WS)

```powershell
Get-Process | Where-Object { ($_.WS * 2) -gt 50mb }

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
-------  ------    -----      ----- -----   ------     -- -----------
   1896      39    50968      30620   264 1,572.55   1104 explorer
  12802      78   188468      81032   753 3,676.39   5676 OUTLOOK
    660       9    36168      26956   143    12.20    988 PowerShell
    561      14     6592      28144   110 1,010.09    496 services
   3476      80    34664      26092   234 ...45.69    876 svchost
    967      30    58804      59496   416   930.97   2508 WINWORD
```

### Bitwise AND operation

```powershell
10 -band 3   # 2
```

### Bitwise OR (inclusive) operation

```powershell
10 -bor 3    # 11
```

### Bitwise XOR (exclusive) operation

```powershell
10 -bxor 3   # 9
```

### Bitwise NOT operation

```powershell
-bnot 10     # -11
```

### Shift-left operation

```powershell
102 -shl 2   # 408
```

### Shift-right operation

```powershell
102 -shr 1   # 51
```

### Bitwise AND binary representation

```powershell
1010      (10)
0011      ( 3)
--------------  bAND
0010      ( 2)
```

### Bitwise OR (inclusive) binary representation

```powershell
1010      (10)
0011      ( 3)
--------------  bOR (inclusive)
1011      (11)
```

### Bitwise OR (exclusive) binary representation

```powershell
1010      (10)
0011      ( 3)
--------------  bXOR (exclusive)
1001      ( 9)
```

### Bitwise NOT binary representation

```powershell
-bnot 10

-11

0000 0000 0000 1010  (10)
------------------------- bNOT
1111 1111 1111 0101  (-11, 0xFFFFFFF5)
```

### Shift-left operation results

```powershell
Expression   Result   Binary Result
------------ -------- ---------------
21 -shl 0    21       0001 0101
21 -shl 1    42       0010 1010
21 -shl 2    84       0101 0100
```

### Shift-right operation results

```powershell
         Expression               Result                             Binary          Hex
  ------------------------ ------------- ---------------------------------- ------------
         21 -shr 0                    21                           00010101         0x15
         21 -shr 1                    10                           00001010         0x0A
         21 -shr 2                     5                           00000101         0x05
         21 -shr 31                    0                           00000000         0x00
         21 -shr 32                   21                           00010101         0x15
         21 -shr 64                   21                           00010101         0x15
         21 -shr 65                   10                           00001010         0x0A
         21 -shr 66                    5                           00000101         0x05
   [int]::MaxValue -shr 1     1073741823   00111111111111111111111111111111   0x3FFFFFFF
   [int]::MinValue -shr 1    -1073741824   11000000000000000000000000000000   0xC0000000
         -1 -shr 1                    -1   11111111111111111111111111111111   0xFFFFFFFF
        (-21 -shr 1)                 -11   11111111111111111111111111110101   0xFFFFFFF5
        (-21 -shr 2)                  -6   11111111111111111111111111111010   0xFFFFFFF4
```
### Creating an array of seven numeric values

```powershell
$A = 22,5,10,8,12,9,80
```

### Creating a single item array

```powershell
$B = ,7
```

### Creating an array using the range operator

```powershell
$C = 5..8
```

### Determining the data type of an array

```powershell
$A.GetType()
```

### Creating a strongly typed integer array

```powershell
[Int32[]]$ia = 1500, 2230, 3350, 4000
```

### Creating a strongly typed array of process objects

```powershell
[Diagnostics.Process[]]$zz = Get-Process
```

### Creating an array of zero or one object using array sub-expression operator (one object)

```powershell
$a = @("Hello World")
$a.Count

1
```

### Creating an array of zero or one object using array sub-expression operator (zero objects)

```powershell
$b = @()
$b.Count

0
```

### Using array operator when number of objects is unknown

```powershell
$p = @(Get-Process Notepad)
```

### Displaying all elements in an array

```powershell
$a

0
1
2
3
4
5
6
7
8
9
```

### Displaying the first element of an array

```powershell
$a[0]

0
```

### Displaying the third element of an array

```powershell
$a[2]

2
```

### Retrieving part of an array using a range operator

```powershell
$a[1..4]

1
2
3
4
```

### Displaying the last three elements of an array (ascending index)

```powershell
$a = 0 .. 9
$a[-3..-1]

7
8
9
```

### Displaying the last three elements of an array (descending index)

```powershell
$a = 0 .. 9
$a[-1..-3]

9
8
7
```

### Using mixed positive and negative indexes (caution: unexpected behavior)

```powershell
$a = 0 .. 9
$a[2..-2]

2
1
0
9
8
```

### Combining ranges and individual elements using plus operator

```powershell
$a = 0 .. 9
$a[0,2+4..6]

0
2
4
5
6
```

### Listing multiple ranges and individual elements

```powershell
$a = 0..9
$a[+0..2+4..6+8]

0
1
2
4
5
6
8
```

### Using a foreach loop to display array elements

```powershell
$a = 0..9
foreach ($element in $a) {
  $element
}

0
1
2
3
4
5
6
7
8
9
```

### Using a for loop to return every other value in an array

```powershell
$a = 0..9
for ($i = 0; $i -le ($a.Length - 1); $i += 2) {
  $a[$i]
}

0
2
4
6
8
```

### Using a while loop to display array elements until a condition is false

```powershell
$a = 0..9
$i=0
while($i -lt 4) {
  $a[$i]
  $i++
}

0
1
2
3
```

### Count and Length properties of an array

```powershell
$a = 0..9
$a.Count
$a.Length

10
10
```

### Jagged array (single-dimensional array containing other arrays)

```powershell
$a = @(
  @(0,1),
  @("b", "c"),
  @(Get-Process)
)

"$a rank: $($a.Rank)"
"$a length: $($a.Length)"
"$a[2] length: $($a[2].Length)"
"Process $a[2][1]: $($a[2][1].ProcessName)"
```

### Multidimensional array creation and access

```powershell
[string[,]]$rank2 = [string[,]]::new(3,2)
$rank2.Rank
$rank2.Length
$rank2[0,0] = 'a'
$rank2[0,1] = 'b'
$rank2[1,0] = 'c'
$rank2[1,1] = 'd'
$rank2[2,0] = 'e'
$rank2[2,1] = 'f'
$rank2[1,1]

2
6
d
```

### Flattening a multidimensional array into a 1-dimensional array

```powershell
$a = "red",$true
$b = (New-Object 'int[,]' 2,2)
$b[0,0] = 10
$b[0,1] = 20
$b[1,0] = 30
$b[1,1] = 40
$c = $a + $b
$a.GetType().Name
$b.GetType().Name
$c.GetType().Name
$c

Object[]
Int32[,]
Object[]
red
True
10
20
30
40
```

### Using the Clear() method on an object array

```powershell
$a = 1, 2, 3
$a.Clear()
$a | % { $null -eq $_ }

True
True
True
```

### Using the Clear() method on a strongly typed integer array

```powershell
[int[]] $intA = 1, 2, 3
$intA.Clear()
$intA

0
0
0
```

### Using ForEach(scriptblock expression) to square elements

```powershell
$a = @(0 .. 3)
$a.ForEach({ $_ * $_})

0
1
4
9
```

### Using ForEach(type convertToType) to cast string dates to [datetime]

```powershell
("1/1/2017", "2/1/2017", "3/1/2017").ForEach([datetime])


Sunday, January 1, 2017 12:00:00 AM
Wednesday, February 1, 2017 12:00:00 AM
Wednesday, March 1, 2017 12:00:00 AM
```

### Using ForEach(string propertyName, object[] newValue) to set LastAccessTime

```powershell
# Set all LastAccessTime properties of files to the current date.
(dir 'C:\Temp').ForEach('LastAccessTime', (Get-Date))
# View the newly set LastAccessTime of all items, and find Unique entries.
(dir 'C:\Temp').ForEach('LastAccessTime') | Get-Unique

Wednesday, June 20, 2018 9:21:57 AM
```

### Using ForEach(string methodName) to convert strings to uppercase

```powershell
("one", "two", "three").ForEach("ToUpper")

ONE
TWO
THREE
```

### Using Where() to select all odd numbers from an array

```powershell
(0..9).Where{ $_ % 2 }

1
3
5
7
9
```

### Using Where() to select all non-empty strings

```powershell
('hi', '', 'there').Where{ $_ }

hi
there
```

### Using Where() with Default mode to get the least accessed file over 100MB

```powershell
# Get the zip files in the current users profile, sorted by LastAccessTime
$Zips = dir $Env:USERPROFILE -Recurse '*.zip' | Sort-Object LastAccessTime
# Get the least accessed file over 100MB
$Zips.Where({$_.Length -gt 100MB}, 'Default', 1)
```

### Using Where() with Last mode to find the last 5 log files created in the past hour

```powershell
$h = (Get-Date).AddHours(-1)
$logs = dir 'C:\' -Recurse '*.log' | Sort-Object CreationTime
# Find the last 5 log files created in the past hour
$logs.Where({$_.CreationTime -gt $h}, 'Last', 5)
```

### Using Where() with SkipUntil mode to find the first available online server

```powershell
$computers = "Server01", "Server02", "Server03", "localhost", "Server04"
# Find the first available online server.
$computers.Where({ Test-Connection $_ }, 'SkipUntil', 1)

localhost
```

### Using Where() with Until mode to retrieve numbers less than or equal to 10

```powershell
(1..50).Where({$_ -gt 10}, 'Until')
# This would perform the same operation.
(1..50).Where({$_ -le 10})

1
2
3
4
5
6
7
8
9
10
```

### Using Where() with Split mode to group running and stopped services

```powershell
$running, $stopped = (Get-Service).Where({$_.Status -eq 'Running'}, 'Split')
$running

Status   Name               DisplayName
------   ----               -----------
Running  Appinfo            Application Information
Running  AudioEndpointBu... Windows Audio Endpoint Builder
Running  Audiosrv           Windows Audio
...

$stopped

Status   Name               DisplayName
------   ----               -----------
Stopped  AJRouter           AllJoyn Router Service
Stopped  ALG                Application Layer Gateway Service
Stopped  AppIDSvc           Application Identity
...
```

### Getting members of an array using Get-Member -InputObject

```powershell
Get-Member -InputObject $a
```

### Getting members of an array using comma prefix

```powershell
,$a | Get-Member
```

### Getting members of a literal array using comma prefix

```powershell
,(1,2,3) | Get-Member
```

### Changing the value of a specific element in an array

```powershell
$a[1] = 10
```

### Changing an array element value using SetValue method

```powershell
$a.SetValue(500,1)
```

### Adding an element to an array using += operator

```powershell
$a = @(0..4)
$a += 5
```

### Creating a new array with selected elements from an existing array

```powershell
$t = $a[0,1 + 3..($a.Length - 1)]
```

### Combining two arrays into a single array using the plus operator

```powershell
$x = 1,3
$y = 5,9
$z = $x + $y
```

### Deleting an array by assigning $null

```powershell
$a = $null
```

### Variable containing no objects has Count and Length of 0

```powershell
PS> $a = $null
PS> $a.Count
0
PS> $a.Length
0
```

### Variable containing one object has Count and Length of 1, and can be indexed

```powershell
PS> $a = 4
PS> $a.Count
1
PS> $a.Length
1
PS> $a[0]
4
PS> $a[-1]
4
```

### Command returning a single string object, Length is string length

```powershell
PS> $result = 'one','two','three','four' | Where-Object {$_ -like 'f*'}
PS> $result.GetType().FullName
System.String
PS> $result
four
PS> $result.Count
1
PS❯ $result.Length
4
```

### Declaring variable as string array for consistent Count/Length behavior

```powershell
PS> [string[]]$result = 'one','two','three','four' |
        Where-Object {$_ -like 'f*'}
PS> $result.GetType().FullName
System.String[]
PS> $result
four
PS> $result.Count
1
PS> $result.Length
1
PS> $result[0].Length
4
```

### Indexing support for Tuple objects

```powershell
PS> $tuple = [Tuple]::Create(1, 'test')
PS> $tuple[0]
1
PS> $tuple[1]
test
PS> $tuple[0..1]
1
test
PS> $tuple[-1]
test
```

### IDictionary<TKey, TValue> indexing behavior (returns $null for non-existent key)

```powershell
PS> [Collections.Generic.Dictionary[string, int]]::new()['nosuchkey']
# No output ($null)
```

### IDictionary<TKey, TValue> Item() method throws exception for non-existent key

```powershell
PS> [Collections.Generic.Dictionary[string, int]]::new().Item('nosuchkey')
GetValueInvocationException: Exception getting "Item": "The given key
'nosuchkey' was not present in the dictionary."
```

### Member-access enumeration gets LastWriteTime for array of files

```powershell
$files = (New-Item -Type File -Force '/temp/t1.txt'),
         (New-Item -Force -Type File '/temp/t2.txt')
$files.LastWriteTime

Friday, June 25, 2021 1:21:17 PM
Friday, June 25, 2021 1:21:17 PM
```

### Member-access enumeration fails to set values on items in a collection

```powershell
$files.LastWriteTime = (Get-Date).AddDays(-1)

InvalidOperation: The property 'LastWriteTime' cannot be found on this object.
Verify that the property exists and can be set.
```

### Setting values on items in a collection using a method

```powershell
$files.set_LastWriteTime((Get-Date).AddDays(-1))
$files.LastWriteTime

Thursday, June 24, 2021 1:23:30 PM
Thursday, June 24, 2021 1:23:30 PM
```

### Finding hidden set methods for FileInfo objects

```powershell
$files | Get-Member -Force -Name set_*

   TypeName: System.IO.FileInfo

Name              MemberType Definition
----              ---------- ----------
Attributes        Property   System.IO.FileAttributes Attributes {get;set;}
CreationTime      Property   datetime CreationTime {get;set;}
CreationTimeUtc   Property   datetime CreationTimeUtc {get;set;}
IsReadOnly        Property   bool IsReadOnly {get;set;}
LastAccessTime    Property   datetime LastAccessTime {get;set;}
LastAccessTimeUtc Property   datetime LastAccessTimeUtc {get;set;}
LastWriteTime     Property   datetime LastWriteTime {get;set;}
LastWriteTimeUtc  Property   datetime LastWriteTimeUtc {get;set;}
```
### Assigning "PowerShell" to $MyShell

```powershell
$MyShell = "PowerShell"
```

### Assigning values to $a

```powershell
$a = 6
$a = 12
```

### Adding process, service objects, strings, and integers to a variable

```powershell
$a = Get-Process
$a += Get-Service
$a += "string"
$a += 12
```

### Assigning sorted services to $a

```powershell
$a = Get-Service | Sort-Object -Property Name
```

### Assigning the result of a conditional statement to $a

```powershell
$a = if ($b -lt 0) { 0 } else { $b }
```

### Assigning an array to a variable

```powershell
$a = "apple", "orange", "lemon", "grape"
```

### Assigning a hash table to a variable

```powershell
$a = @{one=1; two=2; three=3}
```

### Assigning a hexadecimal value to a variable

```powershell
$a = 0x10
```

### Assigning an exponential value to a variable

```powershell
$a = 3.1415e3
```

### Assigning a kilobyte value to a variable

```powershell
$a = 10kb
```

### Demonstrating compound assignment operator scoping

```powershell
$x = 1 # Global scope
& { $x += 1; $x }
```

### Demonstrating regular assignment operator scoping

```powershell
$x = 1 # Global scope
& { $x = $x + 1; $x }
"Global `$x = $x"
```

### Incrementing a numeric value with +=

```powershell
$a = 4
$a += 2
$a

6
```

### Appending a string with +=

```powershell
$a = "Windows"
$a += " PowerShell"
$a

Windows PowerShell
```

### Appending values to an array with +=

```powershell
$a = 1,2,3
$a += 2
$a

1
2
3
2
```

### Appending a string to an array with +=

```powershell
$a += "String"
$a

1
2
3
2
String
```

### Appending a hash table to an existing hash table

```powershell
$a = @{a = 1; b = 2; c = 3}
$a += @{mode = "write"}
$a

Name                           Value
----                           -----
a                              1
b                              2
mode                           write
c                              3
```

### Attempting to append an integer to a hash table (fails)

```powershell
$a = @{a = 1; b = 2; c = 3}
$a += 1

InvalidOperation:
Line |
   2 |  $a += 1
     |  ~~~~~~~
     | A hash table can only be added to another hash table.
```

### Decrementing a numeric value with -=

```powershell
$a = 8
$a -= 2
$a

6
```

### Decrementing an array element with -=

```powershell
$a = 1,2,3
$a[2] -= 1
$a

1
2
2
```

### Deleting all values from a variable by assigning $null

```powershell
$a = $null
```

### Deleting a particular value from an array by assigning $null

```powershell
$a = 1,2,3
$a

1
2
3

$a[1] = $null
$a

1
3
```

### Deleting a variable with Remove-Variable

```powershell
Remove-Variable -Name a
```

### Multiplying a numeric value with *=

```powershell
$a = 3
$a *= 4
$a

12
```

### Appending a string multiple times with *=

```powershell
$a = "file"
$a *= 4
$a

filefilefilefile
```

### Dividing a numeric value with /=

```powershell
$a = 8
$a /=2
$a

4
```

### Dividing an array element with /=

```powershell
$a[1] /= 2
```

### Using the modulus operator %=

```powershell
$a = 7
$a %= 4
$a

3
```

### Incrementing a variable (no return)

```powershell
$a = 7
++$a
$a

8
```

### Incrementing a variable (with return)

```powershell
$a = 7
(++$a)

8
```

### Prefix increment

```powershell
$a = 7
$c = ++$a
$a

8

$c

8
```

### Postfix increment

```powershell
$a = 7
$c = $a++
$a

8

$c

7
```

### Decrementing a variable (no return)

```powershell
$a = 7
--$a
$a

6
```

### Decrementing a variable (with return)

```powershell
(--$a)

5
```

### Prefix decrement

```powershell
$a = 7
$c = --$a
$a

6

$c

6
```

### Postfix decrement

```powershell
$a = 7
$d = $a--
$a

6

$d

7
```

### Null-coalescing assignment operator

```powershell
$x = $null
$x ??= 100
$x

100
```

### Variable with System.Int32 type

```powershell
$a = 6
```

### Finding the .NET type of a variable

```powershell
$a = 6
$a.GetType().FullName

System.Int32
```

### Creating a string variable

```powershell
$a = "6"
$a.GetType().FullName

System.String
```

### String concatenation with +=

```powershell
$a = "file"
$a += 3
$a

file3
```

### Integer addition with += (string cast to int)

```powershell
$a = 6
$a += "3"
$a

9
```

### Casting a variable as a string type

```powershell
[string]$a = 27
$a += 3
$a

273
```

### Casting the first value instead of the variable

```powershell
$a = [string]27
```

### Attempting to recast incompatible data type (fails)

```powershell
$a = "string"
[int]$a

InvalidArgument: Cannot convert value "string" to type "System.Int32". Error:
"The input string 'string' was not in a correct format."
```

### Changing the data type by replacing its value

```powershell
[int]$a = 3
```

### Attempting to assign an incompatible string to a typed integer variable (fails)

```powershell
$a = 3
$a = "string"
[int]$a = 3
$a = "string"

MetadataError:
Line |
   2 |  $a = "string"
     |  ~~~~~~~~~~~~~
     | Cannot convert value "string" to type "System.Int32". Error: "The input
string 'string' was not in a correct format."

[string]$a = "string"
```

### Casting a variable as a string array type

```powershell
[string []] $a = "one", "two", "three"
```

### Specifying a System.DateTime data type

```powershell
[System.DateTime]$a = "5/31/2005"
```

### Multiple assignment

```powershell
$a, $b, $c = 1, 2, 3
```

### Multiple assignment with more values than variables

```powershell
$a, $b, $c = 1, 2, 3, 4, 5
```

### Assigning remaining values from an array to other variables

```powershell
$d, $e, $f = $c
```

### Multiple assignment with fewer values than variables

```powershell
$a, $b, $c = 1, 2
```

### Assigning a single value to multiple variables

```powershell
$a = $b = $c = $d = "three"
```

### Setting a variable value with Set-Variable

```powershell
Set-Variable -Name a -Value 1, 2, 3
```
### Test-WriteError function definition and usage

```powershell
function Test-WriteError
{
    Write-Error "Bad"
    "The `$? variable is: $?"
}

Test-WriteError
"Now the `$? variable is: $?"

Test-WriteError:
Line |
   7 |  Test-WriteError
     |  ~~~~~~~~~~~~~~~
     | Bad
The $? variable is: False
Now the $? variable is: True
```

### Using $input with `pwsh -Command`

```powershell
echo Hello | pwsh -Command """$input World!"""
```

### Using $null as a placeholder in a collection

```powershell
$a = "one", $null, "three"
$a.Count

3
```

### Using $null with ForEach-Object

```powershell
"one", $null, "three" | ForEach-Object {"Hello " + $_}

Hello one
Hello
Hello three
```

### Script demonstrating $null as a placeholder in an array

```powershell
$calendar = @($null, $null, "Meeting", $null, $null, "Team Lunch", $null)
$days = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
        "Friday", "Saturday"
$currentDay = 0
foreach($day in $calendar)
{
    if($day -ne $null)
    {
        "Appointment on $($days[$currentDay]): $day"
    }

    $currentDay++
}

Appointment on Tuesday: Meeting
Appointment on Friday: Team lunch
```

### Checking if a profile has been created

```powershell
Test-Path $PROFILE
```

### Creating a profile

```powershell
New-Item -ItemType File -Path $PROFILE -Force
```

### Opening the profile in NOTEPAD.EXE

```powershell
notepad.exe $PROFILE
```

### Passing $PSBoundParameters to another function

```powershell
function Test1 {
   param($a, $b)

   # Display the parameters in dictionary format.
   $PSBoundParameters
}

function Test2 {
   param($a, $b)

   # Run the Test1 function with $a and $b.
   Test1 @PSBoundParameters
}

Test2 -a Power -b Shell

Key   Value
---   -----
a     Power
b     Shell
```

### Searching conceptual Help topics with $PSHOME

```powershell
Select-String -Pattern Help -Path $PSHOME\en-US\*.txt
```

### Example: Using the $input variable

```powershell
function Test
{
    begin
    {
        $i = 0
    }

    process
    {
        "Iteration: $i"
        $i++
        "`tInput: $input"
        "`tAccess Again: $input"
        $input.Reset()
        "`tAfter Reset: $input"
    }
}

"one","two" | Test

Iteration: 0
    Input: one
    Access Again:
    After Reset: one
Iteration: 1
    Input: two
    Access Again:
    After Reset: two
```

### Process block automatically advances $input

```powershell
$skip = $true
function Skip
{
    begin
    {
        $i = 0
    }

    process
    {
        "Iteration: $i"
        $i++
        if ($skip)
        {
            "`tSkipping"
            $skip = $false
        }
        else
        {
            "`tInput: $input"
        }
    }
}

"one","two" | Skip

Iteration: 0
    Skipping
Iteration: 1
    Input: two
```

### Example 2: Using $input outside the process block

```powershell
Function All
{
    "All Values: $input"
    "Access Again: $input"
    $input.Reset()
    "After Reset: $input"
    $input.MoveNext() | Out-Null
    "After MoveNext: $input"
}

"one","two","three" | All

All Values: one two three
Access Again:
After Reset: one two three
After MoveNext:
```

### Example 3: Using the $input.Current property

```powershell
function Current
{
    begin
    {
        $i = 0
    }

    process
    {
        "Iteration: $i"
        $i++
        "`tBefore MoveNext: $($input.Current)"
        $input.MoveNext() | Out-Null
        "`tAfter MoveNext: $($input.Current)"
        "`tAccess Again: $($input.Current)"
    }
}

"one","two" | Current

Iteration: 0
    Before MoveNext:
    After MoveNext: one
    Access Again: one
Iteration: 1
    Before MoveNext:
    After MoveNext: two
    Access Again: two
```

### Example 4: Using the $foreach variable

```powershell
$i = 0
foreach ($num in ("one","two","three"))
{
    "Iteration: $i"
    $i++
    "`tNum: $num"
    "`tCurrent: $($foreach.Current)"

    if ($foreach.Current -eq "two")
    {
        "Before MoveNext (Current): $($foreach.Current)"
        $foreach.MoveNext() | Out-Null
        "After MoveNext (Current): $($foreach.Current)"
        "Num hasn't changed: $num"
    }
}

Iteration: 0
        Num: one
        Current: one
Iteration: 1
        Num: two
        Current: two
Before MoveNext (Current): two
After MoveNext (Current): three
Num hasn't changed: two
```

### Reset method in a foreach loop (caution: infinite loop possible)

```powershell
$stopLoop = 0
foreach ($num in ("one","two", "three"))
{
    ("`t" * $stopLoop) + "Current: $($foreach.Current)"

    if ($num -eq "two" -and $stopLoop -lt 2)
    {
        $foreach.Reset()
        ("`t" * $stopLoop) + "Reset Loop: $stopLoop"
        $stopLoop++
    }
}

Current: one
Current: two
Reset Loop: 0
        Current: one
        Current: two
        Reset Loop: 1
                Current: one
                Current: two
                Current: three
```

### Example 5: Using the $switch variable

```powershell
$values = "Start", "MoveNext", "NotEvaluated", "Reset", "End"
$stopInfinite = $false
switch ($values)
{
    "MoveNext" {
        "`tMoveNext"
        $switch.MoveNext() | Out-Null
        "`tAfter MoveNext: $($switch.Current)"
    }
    # This case is never evaluated.
    "NotEvaluated" {
        "`tAfterMoveNext: $($switch.Current)"
    }

    "Reset" {
        if (!$stopInfinite)
        {
            "`tReset"
            $switch.Reset()
            $stopInfinite = $true
        }
    }

    default {
        "Default (Current): $($switch.Current)"
    }
}

Default (Current): Start
    MoveNext
    After MoveNext: NotEvaluated
    Reset
Default (Current): Start
    MoveNext
    After MoveNext: NotEvaluated
Default (Current): End
```
### Examples of scalar types evaluating to $false

```powershell
PS> $false -eq ''
True
PS> if ("") { $true } else { $false }
False
PS> if ($null) { $true } else { $false }
False
PS> if ([int]0) { $true } else { $false }
False
PS> if ([double]0.0) { $true } else { $false }
False
```

### Examples of scalar types evaluating to $true

```powershell
# a non-collection type
PS> [bool]@{value = 0}
True
# non-empty strings
PS> if ('hello') { $true } else { $false }
True
PS> [bool]'False'
True
```

### Explicit string parsing for booleans

```powershell
PS> [bool]::Parse('false')
False
PS> [bool]::Parse('True')
True
PS> [bool]::Parse('Not True')
MethodInvocationException: Exception calling "Parse" with "1" argument(s):
"String 'Not True' was not recognized as a valid Boolean."
```

### Examples of collection types evaluating to $false

```powershell
# Empty collections
PS> [bool]@()
False
PS> [bool](Get-ChildItem | Where-Object Name -EQ 'Non-existent-File.txt')
False
```

### Examples of single-element collections

```powershell
$a = @(0)
PS> [bool]$a
False
PS> $b = @(1)
PS> [bool]$b
True
```

### Examples of multi-element collections

```powershell
$c = @(0,0)
PS> [bool]$c
True
```
### Using `break` in a `for` loop

```powershell
for($i=1; $i -le 10; $i++) {
   Write-Host $i
   break
}
```

### Using `break` in a `foreach` loop with a condition

```powershell
$i=0
$varB = 10,20,30,40
foreach ($val in $varB) {
  if ($val -eq 30) {
    break
  }
  $i++
}
Write-Host "30 was found in array index $i"
```

### Using a labeled `break` in a nested loop

```powershell
:myLabel while (<condition 1>) {
  foreach ($item in $items) {
    if (<condition 2>) {
      break myLabel
    }
    $item = $x   # A statement inside the For-loop
  }
}
$a = $c  # A statement after the labeled While-loop
```

### Nesting many labeled loops

```powershell
:red while (<condition1>) {
  :yellow while (<condition2>) {
    while (<condition3>) {
      if ($a) {break}
      if ($b) {break red}
      if ($c) {break yellow}
    }
    Write-Host "After innermost loop"
  }
  Write-Host "After yellow loop"
}
Write-Host "After red loop"
```

### Using `break` in a `switch` statement

```powershell
$var = "word2"
switch -Regex ($var) {
    "word2" {
      Write-Host "Exact" $_
      break
    }

    "word.*" {
      Write-Host "Match on the prefix" $_
      break
    }

    "w.*" {
      Write-Host "Match on at least the first letter" $_
      break
    }

    default {
      Write-Host "No match" $_
      break
    }
}
```

### Using `break` in a `trap` statement

```powershell
function test {
  trap [DivideByZeroException] {
    Write-Host 'divide by zero trapped'
    break
  }

  $i = 3
  'Before loop'
  while ($true) {
     "1 / $i = " + (1 / $i--)
  }
  'After loop'
}
test
```
### `cd..` function usage

```powershell
Set-Location ..
```

### `cd\` function usage

```powershell
Set-Location \
```

### `cd~` function usage

```powershell
Set-Location ~
```

### `help` (alias: `man`) function usage

```powershell
Get-Help <cmdlet-Name>
```

### `oss` function usage

```powershell
Out-String -Stream
```

### `mkdir` (alias: `md`) function usage

```powershell
New-Item -Type Directory
```

### `exec` function usage

```powershell
Switch-Process
```

### Windows Drive Letter Functions - Example Drive Letter usage

```powershell
C:
```
### Comparing objects with a calculated property (modulus of 2)

```powershell
Compare-Object @{p=1} @{p=2} -Property @{ Expression = { $_.p % 2 } }
```

### Converting aliases to an HTML table with a calculated property for parameter count

```powershell
Get-Alias |
  ConvertTo-Html Name,
                     Definition,
                     @{
                        Name='ParameterCount'
                        Expr={$_.Parameters.Keys.Count}
                        Align='Center'
                     } |
        Out-File .\aliases.htm -Force
```

### Formatting custom output for Get-Date with calculated property for depth

```powershell
Get-Date | Format-Custom @{Expr={$_.Date};Depth=1},TimeOfDay
```

### Formatting output from Get-ChildItem with calculated properties for modified time and size

```powershell
Get-ChildItem *.json -File |
  Format-List FullName,
                  @{
                     Name='Modified'
                     Expression={$_.LastWriteTime}
                     FormatString='O'
                  },
                  @{
                     Name='Size'
                     Expression={$_.Length/1KB}
                     FormatString='N2'
                  }
```

### Formatting a table with a calculated property for file type

```powershell
Get-ChildItem -File |
  Sort-Object Extension |
        Format-Table Name, Length -GroupBy @{
          Name='Type'
          Expression={
            switch ($_.Extension) {
              '.md'   {'Content'}
              ''      {'Metacontent'}
              '.ps1'  {'Automation'}
              '.yml'  {'Automation'}
              default {'Configuration'}
            }
          }
        }
```

### Formatting wide output with a calculated property for filename and size

```powershell
Get-ChildItem -File |
  Format-Wide -Property @{e={'{0} ({1:N2}kb)' -f $_.Name,($_.Length/1kb)}}
```

### Grouping objects with a calculated property for content type count

```powershell
Get-ChildItem -File |
  Sort-Object Extension |
        Group-Object -NoElement -Property @{
          Expression={
            switch ($_.Extension) {
              '.md'   {'Content'}
              ''      {'Metacontent'}
              '.ps1'  {'Automation'}
              '.yml'  {'Automation'}
              default {'Configuration'}
            }
          }
        }
```

### Measuring objects with a calculated property for divisibility by 3

```powershell
1..10 | Measure-Object -Property {($_ % 3) -eq 0} -Sum
```

### Selecting objects with a calculated property for parameter count

```powershell
$aliases = Get-Alias c* |
  Select-Object Name,
                    Definition,
                    @{
                        Name='ParameterCount'
                        Expr={$_.Parameters.Keys.Count}
                    }
$aliases | Get-Member
$aliases
```

### Sorting objects with calculated properties for date and units sold

```powershell
Import-Csv C:\temp\sales-data.csv |
  Sort-Object Date, @{Expr={$_.UnitsSold}; Desc=$true}, Salesperson  |
        Select-Object Date, Salesperson, UnitsSold
```

### Sorting objects with direct script block for expression

```powershell
'1', '10', '2' | Sort-Object { [int] $_ }
```
### Calling generic methods - Example with System.Linq.Enumerable

```powershell
[System.Collections.Generic.List[int]]$list = @( 1, 2, 3, 4, 5 )
$result = [System.Linq.Enumerable]::Select[int, float](
    $list,
    [Func[int, float]]{
        param($Item)
        [Math]::Pow($Item, 3)
    }
)
$result
```

Output:
```
1
8
27
64
125
```
### Displaying the contents of the Cert: drive

```powershell
PS Cert:\CurrentUser\> Get-ChildItem
```

### Displaying certificate properties within the Cert: drive

```powershell
$c = Get-Item Cert:\LocalMachine\My\52A149D0393CE8A8D4AF0B172ED667A9E3A1F44E
$c | Format-List DnsNameList, EnhancedKeyUsageList, SendAsTrustedIssuer

# Output:
# DnsNameList          : {SERVER01.contoso.com}
# EnhancedKeyUsageList : {WiFi-Machine (1.3.6.1.4.1.311.42.2.6),
#                        Client Authentication (1.3.6.1.5.5.7.3.2)}
# SendAsTrustedIssuer  : False
```

### Find all CodeSigning certificates

```powershell
Get-ChildItem -Path Cert: -CodeSigningCert -Recurse
```

### Find expired certificates

```powershell
Get-ChildItem -Path Cert:\LocalMachine\WebHosting -ExpiringInDays 30
```

### Find Server SSL Certificates

```powershell
$getChildItemSplat = @{
    Path = 'Cert:\LocalMachine\My', 'Cert:\LocalMachine\WebHosting'
    SSLServerAuthentication = $true
}
Get-ChildItem @getChildItemSplat
```

### Find expired certificates on remote computers

```powershell
$invokeCommandSplat = @{
    ComputerName = 'Srv01', 'Srv02'
    ScriptBlock = {
        Get-ChildItem -Path Cert:\* -Recurse -ExpiringInDays 0
    }
}
Invoke-Command @invokeCommandSplat
```

### Combining filters to find a specific set of certificates

```powershell
[datetime] $ValidThrough = (Get-Date) + (New-TimeSpan -Days 30)
$getChildItemSplat = @{
    Path = 'Cert:\*'
    Recurse = $true
    DnsName = "*fabrikam*"
    Eku = "*Client Authentication*"
}
Get-ChildItem @getChildItemSplat |
    Where-Object {
        $_.SendAsTrustedIssuer -and $_.NotAfter -gt $ValidThrough
    }
```

### Opening the Certificates MMC snap-in

```powershell
Invoke-Item Cert:\CurrentUser\my\6B8223358119BB08840DEE50FD8AF9EA776CE66B
```

### Copying certificates

```powershell
$path = "Cert:\LocalMachine\Root\E2C0F6662D3C569705B4B31FE2CBF3434094B254"
PS Cert:\LocalMachine\> Copy-Item -Path $path -Destination .\CA\

# Error output:
# Copy-Item : Provider operation stopped because the provider doesn't support
# this operation.
```

### Move all SSL Server authentication certs to the WebHosting store

```powershell
Get-ChildItem Cert:\LocalMachine\My -SSLServerAuthentication |
    Move-Item -Destination Cert:\LocalMachine\WebHosting
```

### Delete a Certificate from the CA store

```powershell
Remove-Item Cert:\LocalMachine\CA\5DDC44652E62BF9AA1116DC41DE44AB47C87BDD0
```

### Delete a Certificate using a wildcards in the DNS name

```powershell
Get-ChildItem -Path Cert:\LocalMachine -DnsName *Fabrikam* | Remove-Item
```

### Delete private keys from a remote computer

```powershell
# Enable CredSSP on client
Enable-WSManCredSSP -Role Client -DelegateComputer S1

# Connect to remote computer
Connect-WSMan -ComputerName S1 -Credential Domain01\Admin01

# Enable CredSSP on remote computer
Set-Item -Path WSMan:\S1\Service\Auth\CredSSP -Value $true

# Create remote session
$s = New-PSSession S1 -Authentication CredSSP -Credential Domain01\Admin01

# Remove certificate and private key on remote computer
Invoke-Command -Session $s {
    $removeItemSplat = @{
        Path = 'Cert:\LocalMachine\My\D2D38EBA60CAA1C12055A2E1C83B15AD450110C2'
        DeleteKey = $true
    }
    Remove-Item @removeItemSplat
}
```

### Delete expired Certificates

```powershell
$expired = Get-ChildItem Cert:\LocalMachine\WebHosting -ExpiringInDays 0
$expired | Remove-Item -DeleteKey
```

### Creating certificate stores

```powershell
New-Item -Path Cert:\LocalMachine\CustomStore
```

### Create a new certificate store on a remote computer

```powershell
Invoke-Command -ComputerName Server01 -ScriptBlock {
    New-Item -Path Cert:\LocalMachine\CustomStore
}
```

### Creating client certificates for WS-MAN

```powershell
$newItemSplat = @{
    Path = 'WSMan:\localhost\ClientCertificate'
    Credential = Get-Credential
    Issuer = '1b3fd224d66c6413fe20d21e38b304226d192dfe'
    URI = 'wmicimv2/*'
}
New-Item @newItemSplat
```

### Delete a certificate store from a remote computer

```powershell
Invoke-Command -ComputerName S1, S2 -ScriptBlock {
    Remove-Item -Path Cert:\LocalMachine\TestStore -Recurse
}
```

### Getting help

```powershell
Get-Help Get-ChildItem

Get-Help Get-ChildItem -Path Cert:
```
### Changing the default encoding for Out-File

```powershell
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
```

### Changing the default encoding for all cmdlets with ENCODING parameter

```powershell
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```
### Example 1 - Defining a class with the default constructor

```powershell
class ExampleBook1 {
    [string]   $Name
    [string]   $Author
    [int]      $Pages
    [datetime] $PublishedOn
}

[ExampleBook1]::new()

# Output:
# Name Author Pages PublishedOn
# ---- ------ ----- -----------
#                   0 1/1/0001 12:00:00 AM
```

### Example 2 - Overriding the default constructor

```powershell
class ExampleBook2 {
    [string]   $Name
    [string]   $Author
    [int]      $Pages
    [datetime] $PublishedOn

    ExampleBook2() {
        $this.PublishedOn = (Get-Date).Date
        $this.Pages       = 1
    }
}

[ExampleBook2]::new()

# Output:
# Name Author Pages PublishedOn
# ---- ------ ----- -----------
#                   1 11/1/2023 12:00:00 AM
```

### Example 3 - Defining constructor overloads

```powershell
class ExampleBook3 {
    [string]   $Name
    [string]   $Author
    [int]      $Pages
    [datetime] $PublishedOn

    ExampleBook3([hashtable]$Info) {
        switch ($Info.Keys) {
            'Name'        { $this.Name        = $Info.Name }
            'Author'      { $this.Author      = $Info.Author }
            'Pages'       { $this.Pages       = $Info.Pages }
            'PublishedOn' { $this.PublishedOn = $Info.PublishedOn }
        }
    }

    ExampleBook3(
        [string]   $Name,
        [string]   $Author,
        [int]      $Pages,
        [datetime] $PublishedOn
    ) {
        $this.Name        = $Name
        $this.Author      = $Author
        $this.Pages       = $Pages
        $this.PublishedOn = $PublishedOn
    }

    ExampleBook3([string]$Name, [string]$Author) {
        $this.Name   = $Name
        $this.Author = $Author
    }
}

[ExampleBook3]::new(@{
    Name        = 'The Hobbit'
    Author      = 'J.R.R. Tolkien'
    Pages       = 310
    PublishedOn = '1937-09-21'
})
[ExampleBook3]::new('The Hobbit', 'J.R.R. Tolkien', 310, '1937-09-21')
[ExampleBook3]::new('The Hobbit', 'J.R.R. Tolkien')
[ExampleBook3]::new()

# Output:
# Name       Author         Pages PublishedOn
# ----       ------         ----- -----------
# The Hobbit J.R.R. Tolkien   310 9/21/1937 12:00:00 AM
# The Hobbit J.R.R. Tolkien   310 9/21/1937 12:00:00 AM
# The Hobbit J.R.R. Tolkien     0 1/1/0001 12:00:00 AM
#
# MethodException:
# Line |
#   42 |  [ExampleBook3]::new()
#      |  ~~~~~~~~~~~~~~~~~~~~~
#      | Cannot find an overload for "new" and the argument count: "0".
```

### Example 4 - Chaining constructors with a shared method

```powershell
class ExampleBook4 {
    [string]   $Name
    [string]   $Author
    [datetime] $PublishedOn
    [int]      $Pages

    ExampleBook4() {
        $this.Init()
    }
    ExampleBook4([string]$Name) {
        $this.Init($Name)
    }
    ExampleBook4([string]$Name, [string]$Author) {
        $this.Init($Name, $Author)
    }
    ExampleBook4([string]$Name, [string]$Author, [datetime]$PublishedOn) {
        $this.Init($Name, $Author, $PublishedOn)
    }
    ExampleBook4(
      [string]$Name,
      [string]$Author,
      [datetime]$PublishedOn,
      [int]$Pages
    ) {
        $this.Init($Name, $Author, $PublishedOn, $Pages)
    }

    hidden Init() {
        $this.Init('Unknown')
    }
    hidden Init([string]$Name) {
        $this.Init($Name, 'Unknown')
    }
    hidden Init([string]$Name, [string]$Author) {
        $this.Init($Name, $Author, (Get-Date).Date)
    }
    hidden Init([string]$Name, [string]$Author, [datetime]$PublishedOn) {
        $this.Init($Name, $Author, $PublishedOn, 1)
    }
    hidden Init(
        [string]$Name,
        [string]$Author,
        [datetime]$PublishedOn,
        [int]$Pages
      ) {
        $this.Name        = $Name
        $this.Author      = $Author
        $this.PublishedOn = $PublishedOn
        $this.Pages       = $Pages
    }
}

[ExampleBook4]::new()
[ExampleBook4]::new('The Hobbit')
[ExampleBook4]::new('The Hobbit', 'J.R.R. Tolkien')
[ExampleBook4]::new('The Hobbit', 'J.R.R. Tolkien', (Get-Date '1937-9-21'))
[ExampleBook4]::new(
    'The Hobbit',
    'J.R.R. Tolkien',
    (Get-Date '1937-9-21'),
    310
)

# Output:
# Name       Author         PublishedOn           Pages
# ----       ------         -----------           -----
# Unknown    Unknown        11/1/2023 12:00:00 AM     1
# The Hobbit Unknown        11/1/2023 12:00:00 AM     1
# The Hobbit J.R.R. Tolkien 11/1/2023 12:00:00 AM     1
# The Hobbit J.R.R. Tolkien 9/21/1937 12:00:00 AM     1
# The Hobbit J.R.R. Tolkien 9/21/1937 12:00:00 AM   310
```

### Example 5 - Derived class constructors

```powershell
class BaseExample {
    static [void] DefaultMessage([type]$Type) {
        Write-Verbose "[$($Type.Name)] default constructor"
    }

    static [void] StaticMessage([type]$Type) {
        Write-Verbose "[$($Type.Name)] static constructor"
    }

    static [void] ParamMessage([type]$Type, [Object]$Value) {
        Write-Verbose "[$($Type.Name)] param constructor ($Value)"
    }

    static BaseExample() { [BaseExample]::StaticMessage([BaseExample])  }
    BaseExample()        { [BaseExample]::DefaultMessage([BaseExample]) }
    BaseExample($Value)  { [BaseExample]::ParamMessage([BaseExample], $Value) }
}

class DerivedExample : BaseExample {
    static DerivedExample() { [BaseExample]::StaticMessage([DerivedExample])  }
           DerivedExample() { [BaseExample]::DefaultMessage([DerivedExample]) }

    DerivedExample([int]$Number) : base($Number) {
        [BaseExample]::ParamMessage([DerivedExample], $Number)
    }
    DerivedExample([string]$String) {
        [BaseExample]::ParamMessage([DerivedExample], $String)
    }
}

# Base class constructor output:
$VerbosePreference = 'Continue'
$b = [BaseExample]::new()
# VERBOSE: [BaseExample] static constructor
# VERBOSE: [BaseExample] default constructor

$b = [BaseExample]::new()
# VERBOSE: [BaseExample] default constructor

$b = [BaseExample]::new(1)
# VERBOSE: [BaseExample] param constructor (1)

# Derived class constructor output (in new session):
$VerbosePreference = 'Continue'
$c = [DerivedExample]::new()
# VERBOSE: [BaseExample] static constructor
# VERBOSE: [DerivedExample] static constructor
# VERBOSE: [BaseExample] default constructor
# VERBOSE: [DerivedExample] default constructor

$c = [DerivedExample]::new()
# VERBOSE: [BaseExample] default constructor
# VERBOSE: [DerivedExample] default constructor

$c = [DerivedExample]::new(1)
# VERBOSE: [BaseExample] param constructor (1)
# VERBOSE: [DerivedExample] param constructor (1)

$c = [DerivedExample]::new('foo')
# VERBOSE: [BaseExample] default constructor
# VERBOSE: [DerivedExample] param constructor (foo)
```
### Example 1 - Base class definition

```powershell
class PublishedWork {
    static [PublishedWork[]] $List    = @()
    static [string[]]        $Artists = @()

    static [void] RegisterWork([PublishedWork]$Work) {
        $wName   = $Work.Name
        $wArtist = $Work.Artist
        if ($Work -notin [PublishedWork]::List) {
            Write-Verbose "Adding work '$wName' to works list"
            [PublishedWork]::List += $Work
        } else {
            Write-Verbose "Work '$wName' already registered."
        }
        if ($wArtist -notin [PublishedWork]::Artists) {
            Write-Verbose "Adding artist '$wArtist' to artists list"
            [PublishedWork]::Artists += $wArtist
        } else {
            Write-Verbose "Artist '$wArtist' already registered."
        }
    }

    static [void] ClearRegistry() {
        Write-Verbose "Clearing PublishedWork registry"
        [PublishedWork]::List    = @()
        [PublishedWork]::Artists = @()
    }

    [string] $Name
    [string] $Artist
    [string] $Category

    [void] Init([string]$WorkType) {
        if ([string]::IsNullOrEmpty($this.Category)) {
            $this.Category = "${WorkType}s"
        }
    }

    PublishedWork() {
        $WorkType = $this.GetType().FullName
        $this.Init($WorkType)
        Write-Verbose "Defined a published work of type [$WorkType]"
    }

    PublishedWork([string]$Name, [string]$Artist) {
        $WorkType    = $this.GetType().FullName
        $this.Name   = $Name
        $this.Artist = $Artist
        $this.Init($WorkType)

        Write-Verbose "Defined '$Name' by $Artist as a published work of type [$WorkType]"
    }

    PublishedWork([string]$Name, [string]$Artist, [string]$Category) {
        $WorkType    = $this.GetType().FullName
        $this.Name   = $Name
        $this.Artist = $Artist
        $this.Init($WorkType)

        Write-Verbose "Defined '$Name' by $Artist ($Category) as a published work of type [$WorkType]"
    }

    [void]   Register() { [PublishedWork]::RegisterWork($this) }
    [string] ToString() { return "$($this.Name) by $($this.Artist)" }
}
```

### Example 1a - Derived class without overrides

```powershell
class Album : PublishedWork {
    [string[]] $Genres   = @()
}

$VerbosePreference = 'Continue'
$Albums = @(
    [Album]@{
        Name   = 'The Dark Side of the Moon'
        Artist = 'Pink Floyd'
        Genres = 'Progressive rock', 'Psychedelic rock'
    }
    [Album]@{
        Name   = 'The Wall'
        Artist = 'Pink Floyd'
        Genres = 'Progressive rock', 'Art rock'
    }
    [Album]@{
        Name   = '36 Chambers'
        Artist = 'Wu-Tang Clan'
        Genres = 'Hip hop'
    }
)

$Albums | Format-Table
$Albums | ForEach-Object { [Album]::RegisterWork($_) }
$Albums | ForEach-Object { [PublishedWork]::RegisterWork($_) }

# Output shows Album instances properly initialized with Category

[PublishedWork]::ClearRegistry()
$Albums.Register()

[pscustomobject]@{
    '[PublishedWork]::List'    = [PublishedWork]::List -join ",`n"
    '[Album]::List'            = [Album]::List -join ",`n"
    '[PublishedWork]::Artists' = [PublishedWork]::Artists -join ",`n"
    '[Album]::Artists'         = [Album]::Artists -join ",`n"
    'IsSame::List'             = (
        [PublishedWork]::List.Count -eq [Album]::List.Count -and
        [PublishedWork]::List.ToString() -eq [Album]::List.ToString()
    )
    'IsSame::Artists'          = (
        [PublishedWork]::Artists.Count -eq [Album]::Artists.Count -and
        [PublishedWork]::Artists.ToString() -eq [Album]::Artists.ToString()
    )
} | Format-List
```

### Example 1b - Derived class with overrides

```powershell
class Illustration : PublishedWork {
    static [string[]] $Artists = @()

    static [void] RegisterIllustration([Illustration]$Work) {
        $wArtist = $Work.Artist

        [PublishedWork]::RegisterWork($Work)

        if ($wArtist -notin [Illustration]::Artists) {
            Write-Verbose "Adding illustrator '$wArtist' to artists list"
            [Illustration]::Artists += $wArtist
        } else {
            Write-Verbose "Illustrator '$wArtist' already registered."
        }
    }

    [string] $Category = 'Illustrations'
    [string] $Medium   = 'Unknown'

    [string] ToString() {
        return "$($this.Name) by $($this.Artist) ($($this.Medium))"
    }

    Illustration() {
        Write-Verbose 'Defined an illustration'
    }

    Illustration([string]$Name, [string]$Artist) : base($Name, $Artist) {
        Write-Verbose "Defined '$Name' by $Artist ($($this.Medium)) as an illustration"
    }

    Illustration([string]$Name, [string]$Artist, [string]$Medium) {
        $this.Name = $Name
        $this.Artist = $Artist
        $this.Medium = $Medium

        Write-Verbose "Defined '$Name' by $Artist ($Medium) as an illustration"
    }
}

$Illustrations = @(
    [Illustration]@{
        Name   = 'The Funny Thing'
        Artist = 'Wanda Gág'
        Medium = 'Lithography'
    }
    [Illustration]::new('Millions of Cats', 'Wanda Gág')
    [Illustration]::new(
      'The Lion and the Mouse',
      'Jerry Pinkney',
      'Watercolor'
    )
)

$Illustrations | Format-Table
$Illustrations | ForEach-Object { [Illustration]::RegisterIllustration($_) }
$Illustrations | ForEach-Object { [PublishedWork]::RegisterWork($_) }
"Published work artists: $([PublishedWork]::Artists -join ', ')"
"Illustration artists: $([Illustration]::Artists -join ', ')"

# Call ToString on the static LIST property
[PublishedWork]::List | ForEach-Object -Process { $_.ToString() }
```

### Example 2 - Initial Temperature class definition

```powershell
class Temperature {
    [float]            $Degrees
    [TemperatureScale] $Scale

    Temperature() {}
    Temperature([float] $Degrees)          { $this.Degrees = $Degrees }
    Temperature([TemperatureScale] $Scale) { $this.Scale = $Scale }
    Temperature([float] $Degrees, [TemperatureScale] $Scale) {
        $this.Degrees = $Degrees
        $this.Scale   = $Scale
    }

    [float] ToKelvin() {
        switch ($this.Scale) {
            Celsius    { return $this.Degrees + 273.15 }
            Fahrenheit { return ($this.Degrees + 459.67) * 5/9 }
        }
        return $this.Degrees
    }
    [float] ToCelsius() {
        switch ($this.Scale) {
            Fahrenheit { return ($this.Degrees - 32) * 5/9 }
            Kelvin     { return $this.Degrees - 273.15 }
        }
        return $this.Degrees
    }
    [float] ToFahrenheit() {
        switch ($this.Scale) {
            Celsius    { return $this.Degrees * 9/5 + 32 }
            Kelvin     { return $this.Degrees * 9/5 - 459.67 }
        }
        return $this.Degrees
    }
}

enum TemperatureScale {
    Celsius    = 0
    Fahrenheit = 1
    Kelvin     = 2
}

$Celsius    = [Temperature]::new()
$Fahrenheit = [Temperature]::new([TemperatureScale]::Fahrenheit)
$Kelvin     = [Temperature]::new(0, 'Kelvin')

$Celsius, $Fahrenheit, $Kelvin

"The temperatures are: $Celsius, $Fahrenheit, $Kelvin"

[Temperature]::new() -eq $Celsius

$Celsius -gt $Kelvin
```

### Example 2a - Temperature class implementing IFormattable

```powershell
class Temperature : System.IFormattable {
    [float]            $Degrees
    [TemperatureScale] $Scale

    Temperature() {}
    Temperature([float] $Degrees)          { $this.Degrees = $Degrees }
    Temperature([TemperatureScale] $Scale) { $this.Scale = $Scale }
    Temperature([float] $Degrees, [TemperatureScale] $Scale) {
        $this.Degrees = $Degrees
        $this.Scale = $Scale
    }

    [float] ToKelvin() {
        switch ($this.Scale) {
            Celsius { return $this.Degrees + 273.15 }
            Fahrenheit { return ($this.Degrees + 459.67) * 5 / 9 }
        }
        return $this.Degrees
    }
    [float] ToCelsius() {
        switch ($this.Scale) {
            Fahrenheit { return ($this.Degrees - 32) * 5 / 9 }
            Kelvin { return $this.Degrees - 273.15 }
        }
        return $this.Degrees
    }
    [float] ToFahrenheit() {
        switch ($this.Scale) {
            Celsius { return $this.Degrees * 9 / 5 + 32 }
            Kelvin { return $this.Degrees * 9 / 5 - 459.67 }
        }
        return $this.Degrees
    }

    [string] ToString(
        [string]$Format,
        [System.IFormatProvider]$FormatProvider
    ) {
        if ([string]::IsNullOrEmpty($Format)) {
            $Format = switch ($this.Scale) {
                Celsius    { 'C' }
                Fahrenheit { 'F' }
                Kelvin     { 'K' }
            }
        }
        if ($null -eq $FormatProvider) {
            $FormatProvider = [cultureinfo]::CurrentCulture
        }
        switch ($Format) {
            'C' {
                return $this.ToCelsius().ToString('F2', $FormatProvider) + '°C'
            }
            'F' {
                return $this.ToFahrenheit().ToString('F2', $FormatProvider) + '°F'
            }
            'K' {
                return $this.ToKelvin().ToString('F2', $FormatProvider) + '°K'
            }
        }
        throw [System.FormatException]::new(
            "Unknown format: '$Format'. Valid Formats are 'C', 'F', and 'K'"
        )
    }

    [string] ToString([string]$Format) {
        return $this.ToString($Format, $null)
    }

    [string] ToString() {
        return $this.ToString($null, $null)
    }
}

enum TemperatureScale {
    Celsius    = 0
    Fahrenheit = 1
    Kelvin     = 2
}

$Temp = [Temperature]::new()
"The temperature is $Temp"
$Temp.ToString()
$Temp.ToString('K')
$Temp.ToString('F', $null)
```

### Example 2b - Temperature class implementing IFormattable and IEquatable

```powershell
class Temperature : System.IFormattable, System.IEquatable[Object] {
    [float]            $Degrees
    [TemperatureScale] $Scale

    Temperature() {}
    Temperature([float] $Degrees)          { $this.Degrees = $Degrees }
    Temperature([TemperatureScale] $Scale) { $this.Scale = $Scale }
    Temperature([float] $Degrees, [TemperatureScale] $Scale) {
        $this.Degrees = $Degrees
        $this.Scale = $Scale
    }

    [float] ToKelvin() {
        switch ($this.Scale) {
            Celsius { return $this.Degrees + 273.15 }
            Fahrenheit { return ($this.Degrees + 459.67) * 5 / 9 }
        }
        return $this.Degrees
    }
    [float] ToCelsius() {
        switch ($this.Scale) {
            Fahrenheit { return ($this.Degrees - 32) * 5 / 9 }
            Kelvin { return $this.Degrees - 273.15 }
        }
        return $this.Degrees
    }
    [float] ToFahrenheit() {
        switch ($this.Scale) {
            Celsius { return $this.Degrees * 9 / 5 + 32 }
            Kelvin { return $this.Degrees * 9 / 5 - 459.67 }
        }
        return $this.Degrees
    }

    [string] ToString(
        [string]$Format,
        [System.IFormatProvider]$FormatProvider
    ) {
        if ([string]::IsNullOrEmpty($Format)) {
            $Format = switch ($this.Scale) {
                Celsius    { 'C' }
                Fahrenheit { 'F' }
                Kelvin     { 'K' }
            }
        }
        if ($null -eq $FormatProvider) {
            $FormatProvider = [cultureinfo]::CurrentCulture
        }
        switch ($Format) {
            'C' {
                return $this.ToCelsius().ToString('F2', $FormatProvider) + '°C'
            }
            'F' {
                return $this.ToFahrenheit().ToString('F2', $FormatProvider) + '°F'
            }
            'K' {
                return $this.ToKelvin().ToString('F2', $FormatProvider) + '°K'
            }
        }
        throw [System.FormatException]::new(
            "Unknown format: '$Format'. Valid Formats are 'C', 'F', and 'K'"
        )
    }

    [string] ToString([string]$Format) {
        return $this.ToString($Format, $null)
    }

    [string] ToString() {
        return $this.ToString($null, $null)
    }

    [bool] Equals([Object]$Other) {
        if ($null -eq $Other) {
            return $false
        }

        $OtherTemperature = $Other -as [Temperature]
        if ($null -eq $OtherTemperature) {
            return $false
        }

        return $this.ToKelvin() -eq $OtherTemperature.ToKelvin()
    }
}

enum TemperatureScale {
    Celsius    = 0
    Fahrenheit = 1
    Kelvin     = 2
}

$Celsius    = [Temperature]::new()
$Fahrenheit = [Temperature]::new(32, 'Fahrenheit')
$Kelvin     = [Temperature]::new([TemperatureScale]::Kelvin)

@"
Temperatures are: $Celsius, $Fahrenheit, $Kelvin
`$Celsius.Equals(`$Fahrenheit) = $($Celsius.Equals($Fahrenheit))
`$Celsius -eq `$Fahrenheit     = $($Celsius -eq $Fahrenheit)
`$Celsius -ne `$Kelvin         = $($Celsius -ne $Kelvin)
"@
```

### Example 2c - Temperature class implementing IFormattable, IEquatable, and IComparable

```powershell
class Temperature : System.IFormattable,
                    System.IComparable,
                    System.IEquatable[Object] {
    # Instance properties
    [float]            $Degrees
    [TemperatureScale] $Scale

    # Constructors
    Temperature() {}
    Temperature([float] $Degrees)          { $this.Degrees = $Degrees }
    Temperature([TemperatureScale] $Scale) { $this.Scale = $Scale }
    Temperature([float] $Degrees, [TemperatureScale] $Scale) {
        $this.Degrees = $Degrees
        $this.Scale = $Scale
    }

    [float] ToKelvin() {
        switch ($this.Scale) {
            Celsius { return $this.Degrees + 273.15 }
            Fahrenheit { return ($this.Degrees + 459.67) * 5 / 9 }
        }
        return $this.Degrees
    }
    [float] ToCelsius() {
        switch ($this.Scale) {
            Fahrenheit { return ($this.Degrees - 32) * 5 / 9 }
            Kelvin { return $this.Degrees - 273.15 }
        }
        return $this.Degrees
    }
    [float] ToFahrenheit() {
        switch ($this.Scale) {
            Celsius { return $this.Degrees * 9 / 5 + 32 }
            Kelvin { return $this.Degrees * 9 / 5 - 459.67 }
        }
        return $this.Degrees
    }

    [string] ToString(
        [string]$Format,
        [System.IFormatProvider]$FormatProvider
    ) {
        if ([string]::IsNullOrEmpty($Format)) {
            $Format = switch ($this.Scale) {
                Celsius    { 'C' }
                Fahrenheit { 'F' }
                Kelvin     { 'K' }
            }
        }
        if ($null -eq $FormatProvider) {
            $FormatProvider = [cultureinfo]::CurrentCulture
        }
        switch ($Format) {
            'C' {
                return $this.ToCelsius().ToString('F2', $FormatProvider) + '°C'
            }
            'F' {
                return $this.ToFahrenheit().ToString('F2', $FormatProvider) + '°F'
            }
            'K' {
                return $this.ToKelvin().ToString('F2', $FormatProvider) + '°K'
            }
        }
        throw [System.FormatException]::new(
            "Unknown format: '$Format'. Valid Formats are 'C', 'F', and 'K'"
        )
    }

    [string] ToString([string]$Format) {
        return $this.ToString($Format, $null)
    }

    [string] ToString() {
        return $this.ToString($null, $null)
    }

    [bool] Equals([Object]$Other) {
        if ($null -eq $Other) {
            return $false
        }

        $OtherTemperature = $Other -as [Temperature]
        if ($null -eq $OtherTemperature) {
            return $false
        }

        return $this.ToKelvin() -eq $OtherTemperature.ToKelvin()
    }
    [int] CompareTo([Object]$Other) {
        if ($null -eq $Other) {
            return 1
        }
        $OtherTemperature = $Other -as [Temperature]
        if ($null -eq $OtherTemperature) {
            throw [System.ArgumentException]::new(
                "Object must be of type 'Temperature'."
            )
        }
        return $this.ToKelvin().CompareTo($OtherTemperature.ToKelvin())
    }
}

enum TemperatureScale {
    Celsius    = 0
    Fahrenheit = 1
    Kelvin     = 2
}

$Celsius    = [Temperature]::new()
$Fahrenheit = [Temperature]::new(32, 'Fahrenheit')
$Kelvin     = [Temperature]::new([TemperatureScale]::Kelvin)

@"
Temperatures are: $Celsius, $Fahrenheit, $Kelvin
`$Celsius.Equals(`$Fahrenheit)    = $($Celsius.Equals($Fahrenheit))
`$Celsius.Equals(`$Kelvin)        = $($Celsius.Equals($Kelvin))
`$Celsius.CompareTo(`$Fahrenheit) = $($Celsius.CompareTo($Fahrenheit))
`$Celsius.CompareTo(`$Kelvin)     = $($Celsius.CompareTo($Kelvin))
`$Celsius -lt `$Fahrenheit        = $($Celsius -lt $Fahrenheit)
`$Celsius -le `$Fahrenheit        = $($Celsius -le $Fahrenheit)
`$Celsius -eq `$Fahrenheit        = $($Celsius -eq $Fahrenheit)
`$Celsius -gt `$Kelvin            = $($Celsius -gt $Kelvin)
"@
```

### Example 3 - Inheriting from a generic base class with built-in type

```powershell
class ExampleStringList : System.Collections.Generic.List[string] {}

$List = [ExampleStringList]::new()
$List.AddRange([string[]]@('a','b','c'))
$List.GetType() | Format-List -Property Name, BaseType
$List
```

### Example 3a - Inheriting from a generic base class with custom type

```powershell
class ExampleItem {
    [string] $Name
    [string] ToString() { return $this.Name }
}

class ExampleItemList : System.Collections.Generic.List[ExampleItem] {}

$List = [ExampleItemList]::new()
$List.AddRange([ExampleItem[]]@(
    [ExampleItem]@{ Name = 'Foo' }
    [ExampleItem]@{ Name = 'Bar' }
    [ExampleItem]@{ Name = 'Baz' }
))
$List.GetType() | Format-List -Property Name, BaseType
$List
```

### Example 3b - Calling a base class method from derived class

```powershell
class BaseClass {
    [bool] IsTrue() { return $true }
}
class DerivedClass : BaseClass {
    [bool] IsTrue()     { return $false }
    [bool] BaseIsTrue() { return ([BaseClass]$this).IsTrue() }
}

@"
[BaseClass]::new().IsTrue()        = $([BaseClass]::new().IsTrue())
[DerivedClass]::new().IsTrue()     = $([DerivedClass]::new().IsTrue())
[DerivedClass]::new().BaseIsTrue() = $([DerivedClass]::new().BaseIsTrue())
"@
```
### Example 1 - Minimal method definition

```powershell
class ExampleCube1 {
    [float]   $Height
    [float]   $Length
    [float]   $Width

    [float] GetVolume() { return $this.Height * $this.Length * $this.Width }
}

$box = [ExampleCube1]@{
    Height = 2
    Length = 2
    Width  = 3
}

$box.GetVolume()

# Output: 12
```

### Example 2 - Method with parameters

```powershell
class ExampleCube2 {
    [float]   $Height
    [float]   $Length
    [float]   $Width

    [float] GetVolume() { return $this.Height * $this.Length * $this.Width }
    [float] GetWeight([float]$Density) {
        return $this.GetVolume() * $Density
    }
}

$cube = [ExampleCube2]@{
    Height = 2
    Length = 2
    Width  = 3
}

$cube.GetWeight(2.5)

# Output: 30
```

### Example 3 - Method without output

```powershell
class ExampleCube3 {
    [float]   $Height
    [float]   $Length
    [float]   $Width

    [float] GetVolume() {
        $this.Validate()

        return $this.Height * $this.Length * $this.Width
    }

    [void] Validate() {
        $InvalidProperties = @()
        foreach ($Property in @('Height', 'Length', 'Width')) {
            if ($this.$Property -le 0) {
                $InvalidProperties += $Property
            }
        }

        if ($InvalidProperties.Count -gt 0) {
            $Message = @(
                'Invalid cube properties'
                "('$($InvalidProperties -join "', '")'):"
                "Cube dimensions must all be positive numbers."
            ) -join ' '
            throw $Message
        }
    }
}

$Cube = [ExampleCube3]@{ Length = 1 ; Width = -1 }
$Cube

$Cube.GetVolume()
```

### Example 4 - Static method with overloads

```powershell
class ExampleCube4 {
    [float]   $Height
    [float]   $Length
    [float]   $Width

    static [float] GetVolume(
        [float]$Height,
        [float]$Length,
        [float]$Width,
        [boolean]$Strict
    ) {
        $Signature = "[ExampleCube4]::GetVolume({0}, {1}, {2}, {3})"
        $Signature = $Signature -f $Height, $Length, $Width, $Strict
        Write-Verbose "Called $Signature"

        if ($Strict) {
            [ValidateScript({$_ -gt 0 })]$Height = $Height
            [ValidateScript({$_ -gt 0 })]$Length = $Length
            [ValidateScript({$_ -gt 0 })]$Width  = $Width
        }

        return $Height * $Length * $Width
    }

    static [float] GetVolume([float]$Height, [float]$Length, [float]$Width) {
        $Signature = "[ExampleCube4]::GetVolume($Height, $Length, $Width)"
        Write-Verbose "Called $Signature"

        return [ExampleCube4]::GetVolume($Height, $Length, $Width, $true)
    }

    [float] GetVolume() {
        Write-Verbose "Called `$this.GetVolume()"
        return [ExampleCube4]::GetVolume(
            $this.Height,
            $this.Length,
            $this.Width
        )
    }
}

$VerbosePreference = 'Continue'
$Cube = [ExampleCube4]@{ Height = 2 ; Length = 2 }
$Cube.GetVolume()

# Calling the static method directly with STRICT parameter as $false
[ExampleCube4]::GetVolume($Cube.Height, $Cube.Length, $Cube.Width, $false)
```

### Method signatures and overloads - CardDeck example

```powershell
class CardDeck {
    [string[]]$Cards  = @()
    hidden [string[]]$Dealt  = @()
    hidden [string[]]$Suits  = @('Clubs', 'Diamonds', 'Hearts', 'Spades')
    hidden [string[]]$Values = 2..10 + @('Jack', 'Queen', 'King', 'Ace')

    CardDeck() {
        foreach($Suit in $this.Suits) {
            foreach($Value in $this.Values) {
                $this.Cards += "$Value of $Suit"
            }
        }
        $this.Shuffle()
    }

    [void] Shuffle() {
        $this.Cards = $this.Cards + $this.Dealt | Where-Object -FilterScript {
             -not [string]::IsNullOrEmpty($_)
        } | Get-Random -Count $this.Cards.Count
    }

    [string] Deal() {
        if ($this.Cards.Count -eq 0) { throw "There are no cards left." }

        $Card        = $this.Cards[0]
        $this.Cards  = $this.Cards[1..$this.Cards.Count]
        $this.Dealt += $Card

        return $Card
    }

    [string[]] Deal([int]$Count) {
        if ($Count -gt $this.Cards.Count) {
            throw "There are only $($this.Cards.Count) cards left."
        } elseif ($Count -lt 1) {
            throw "You must deal at least 1 card."
        }

        return (1..$Count | ForEach-Object { $this.Deal() })
    }
}
```

### Derived class methods - Base class definition

```powershell
class BaseClass {
    static [datetime] Now() {
        return Get-Date
    }
    static [datetime] DaysAgo([int]$Count) {
        return [BaseClass]::Now().AddDays(-$Count)
    }

    [datetime] $TimeStamp = [BaseClass]::Now()

    [string] ToString() {
        return $this.TimeStamp.ToString()
    }

    [void] SetTimeStamp([datetime]$TimeStamp) {
        $this.TimeStamp = $TimeStamp
    }
    [void] SetTimeStamp() {
        $this.TimeStamp = [BaseClass]::Now()
    }
}
```

### Derived class methods - Derived classes

```powershell
class DerivedClassA : BaseClass     {}
class DerivedClassB : BaseClass     {
    static [string] DaysAgo([int]$Count) {
        return [BaseClass]::DaysAgo($Count).ToString('yyyy-MM-dd')
    }
    [string] ToString() {
        return $this.TimeStamp.ToString('yyyy-MM-dd')
    }
}
class DerivedClassC : BaseClass {
    [void] SetTimeStamp() {
        $this.SetTimeStamp([BaseClass]::Now().AddDays(-10))
    }
}

# Calling static Now() method for each class
"[BaseClass]::Now()     => $([BaseClass]::Now())"
"[DerivedClassA]::Now() => $([DerivedClassA]::Now())"
"[DerivedClassB]::Now() => $([DerivedClassB]::Now())"
"[DerivedClassC]::Now() => $([DerivedClassC]::Now())"

# Calling the DaysAgo() static method of each class
"[BaseClass]::DaysAgo(3)     => $([BaseClass]::DaysAgo(3))"
"[DerivedClassA]::DaysAgo(3) => $([DerivedClassA]::DaysAgo(3))"
"[DerivedClassB]::DaysAgo(3) => $([DerivedClassB]::DaysAgo(3))"
"[DerivedClassC]::DaysAgo(3) => $([DerivedClassC]::DaysAgo(3))"

# String representation of instances
"`$base = [BaseClass]::new()     => $($base = [BaseClass]::new(); $base)"
"`$a    = [DerivedClassA]::new() => $($a = [DerivedClassA]::new(); $a)"
"`$b    = [DerivedClassB]::new() => $($b = [DerivedClassB]::new(); $b)"
"`$c    = [DerivedClassC]::new() => $($c = [DerivedClassC]::new(); $c)"

# Calling SetTimeStamp with parameter
[datetime]$Stamp = '2024-10-31'
"`$base.SetTimeStamp(`$Stamp) => $($base.SetTimeStamp($Stamp) ; $base)"
"`$a.SetTimeStamp(`$Stamp)    => $($a.SetTimeStamp($Stamp); $a)"
"`$b.SetTimeStamp(`$Stamp)    => $($b.SetTimeStamp($Stamp); $b)"
"`$c.SetTimeStamp(`$Stamp)    => $($c.SetTimeStamp($Stamp); $c)"

# Calling SetTimeStamp without parameters
"`$base.SetTimeStamp() => $($base.SetTimeStamp() ; $base)"
"`$a.SetTimeStamp()    => $($a.SetTimeStamp(); $a)"
"`$b.SetTimeStamp()    => $($b.SetTimeStamp(); $b)"
"`$c.SetTimeStamp()    => $($c.SetTimeStamp(); $c)"
```

### Defining methods with default parameter values and validation attributes

```powershell
class CookieJar {
    [int] $Cookies = 12

    static [hashtable[]] $MemberDefinitions = @(
        @{
            MemberName = 'Eat'
            MemberType = 'ScriptMethod'
            Value      = {
                param(
                    [ValidateScript({ $_ -ge 1 -and $_ -le $this.Cookies })]
                    [int] $Count = 1
                )

                $this.Cookies -= $Count
                if ($Count -eq 1) {
                    "You ate 1 cookie. There are $($this.Cookies) left."
                } else {
                    "You ate $Count cookies. There are $($this.Cookies) left."
                }
            }
        }
    )

    static CookieJar() {
        $TypeName = [CookieJar].Name
        foreach ($Definition in [CookieJar]::MemberDefinitions) {
            Update-TypeData -TypeName $TypeName @Definition
        }
    }
}

$Jar = [CookieJar]::new()
$Jar.Eat(1)
$Jar.Eat()
$Jar.Eat(20)
$Jar.Eat(6)
```
### Example 1 - Minimal class properties

```powershell
class ExampleProject1 {
    [string]   $Name
    [int]      $Size
    [bool]     $Completed
    [string]   $Assignee
    [datetime] $StartDate
    [datetime] $EndDate
    [datetime] $DueDate
}

[ExampleProject1]::new()

$null -eq ([ExampleProject1]::new()).Name
```

### Example 2 - Class properties with custom types

```powershell
enum ProjectState {
    NotTriaged
    ReadyForWork
    Committed
    Blocked
    InProgress
    Done
}

class ProjectAssignee {
    [string] $DisplayName
    [string] $UserName

    [string] ToString() {
        return "$($this.DisplayName) ($($this.UserName))"
    }
}

class ExampleProject2 {
    [string]          $Name
    [int]             $Size
    [ProjectState]    $State
    [ProjectAssignee] $Assignee
    [datetime]        $StartDate
    [datetime]        $EndDate
    [datetime]        $DueDate
}

[ExampleProject2]@{
    Name     = 'Class Property Documentation'
    Size     = 8
    State    = 'InProgress'
    Assignee = @{
        DisplayName = 'Mikey Lombardi'
        UserName    = 'michaeltlombardi'
    }
    StartDate = '2023-10-23'
    DueDate   = '2023-10-27'
}
```

### Example 3 - Class property with a validation attribute

```powershell
class ExampleProject3 {
                           [string]   $Name
    [ValidateRange(0, 16)] [int]      $Size
                           [bool]     $Completed
                           [string]   $Assignee
                           [datetime] $StartDate
                           [datetime] $EndDate
                           [datetime] $DueDate
}

$project = [ExampleProject3]::new()
$project

$project.Size = 8
$project

$project.Size = 32
$project.Size = -1

$project
```

### Example 4 - Class property with an explicit default value

```powershell
class ExampleProject4 {
    [string]   $Name
    [int]      $Size
    [bool]     $Completed
    [string]   $Assignee
    [datetime] $StartDate = (Get-Date).Date
    [datetime] $EndDate
    [datetime] $DueDate
}

[ExampleProject4]::new()

[ExampleProject4]::new().StartDate -eq (Get-Date).Date
```

### Example 5 - Hidden class property

```powershell
class ExampleProject5 {
           [string]   $Name
           [int]      $Size
           [bool]     $Completed
           [string]   $Assignee
           [datetime] $StartDate
           [datetime] $EndDate
           [datetime] $DueDate
    hidden [string]   $Guid      = (New-Guid).Guid
}

$project = [ExampleProject5]::new()

"Project GUID: $($project.Guid)"

$project

$project | Get-Member -MemberType Properties | Format-Table
```

### Example 6 - Static class property

```powershell
class ExampleProject6 {
           [string]            $Name
           [int]               $Size
           [bool]              $Completed
           [string]            $Assignee
           [datetime]          $StartDate
           [datetime]          $EndDate
           [datetime]          $DueDate
    hidden [string]            $Guid     = (New-Guid).Guid
    static [ExampleProject6[]] $Projects = @()

    ExampleProject6() {
        [ExampleProject6]::Projects += $this
    }
}

"Project Count: $([ExampleProject6]::Projects.Count)"

$project1 = [ExampleProject6]@{ Name = 'Project_1' }
$project2 = [ExampleProject6]@{ Name = 'Project_2' }

[ExampleProject6]::Projects | Select-Object -Property Name, Guid
```

### Example 7 - Defining a property in the constructor

```powershell
class ExampleProject7 {
    [string]   $Name
    [int]      $Size
    [bool]     $Completed
    [string]   $Assignee
    [datetime] $StartDate
    [datetime] $EndDate
    [datetime] $DueDate

    static [hashtable[]] $MemberDefinitions = @(
        @{
            MemberName = 'Duration'
            MemberType = 'ScriptProperty'
            Value      = {
                [datetime]$UnsetDate = 0

                $StartNotSet   = $this.StartDate -eq $UnsetDate
                $EndNotSet     = $this.EndDate   -eq $UnsetDate
                $StartAfterEnd = $this.StartDate -gt $this.EndDate

                if ($StartNotSet -or $EndNotSet -or $StartAfterEnd) {
                    return $null
                }

                return $this.EndDate - $this.StartDate
            }
        }
    )

    static ExampleProject7() {
        $TypeName = [ExampleProject7].Name
        foreach ($Definition in [ExampleProject7]::MemberDefinitions) {
            Update-TypeData -TypeName $TypeName @Definition
        }
    }

    ExampleProject7() {}

    ExampleProject7([string]$Name) {
        $this.Name = $Name
    }
}

$Project = [ExampleProject7]::new()
$Project

$null -eq $Project.Duration

$Project.StartDate = '2023-01-01'
$Project.EndDate   = '2023-01-08'

$Project
```

### Default property values - ProjectTask example

```powershell
class ProjectTask {
    [string] $Name
    [string] $Description
    [string] $Guid = (New-Guid).Guid
}

[ProjectTask]::new()
```

### Derived class properties - Base and derived classes

```powershell
class BaseClass {
    static [string] $StaticProperty = 'Static'
    [string] $InstanceProperty = 'Instance'
}
class DerivedClassA : BaseClass     {}
class DerivedClassB : BaseClass     {}
class DerivedClassC : DerivedClassB {
    [string] $InstanceProperty
}
class DerivedClassD : BaseClass {
    static [string] $StaticProperty = 'Override'
    [string] $InstanceProperty = 'Override'
}

"Base instance      => $([BaseClass]::new().InstanceProperty)"
"Derived instance A => $([DerivedClassA]::new().InstanceProperty)"
"Derived instance B => $([DerivedClassB]::new().InstanceProperty)"
"Derived instance C => $([DerivedClassC]::new().InstanceProperty)"
"Derived instance D => $([DerivedClassD]::new().InstanceProperty)"

"Base static        => $([BaseClass]::StaticProperty)"
"Derived static A   => $([DerivedClassA]::StaticProperty)"
"Derived static B   => $([DerivedClassB]::StaticProperty)"
"Derived static C   => $([DerivedClassC]::StaticProperty)"
"Derived static D   => $([DerivedClassD]::StaticProperty)"

[DerivedClassA]::StaticProperty = 'Updated from A'
"Base static        => $([BaseClass]::StaticProperty)"
"Derived static A   => $([DerivedClassA]::StaticProperty)"
"Derived static B   => $([DerivedClassB]::StaticProperty)"
"Derived static C   => $([DerivedClassC]::StaticProperty)"
"Derived static D   => $([DerivedClassD]::StaticProperty)"
```

### Defining alias properties

```powershell
class OperablePair {
    [int] $x
    [int] $y

    static [hashtable[]] $MemberDefinitions = @(
            @{
                MemberType = 'AliasProperty'
                MemberName = 'LeftHandSide'
                Value      = 'x'
            }
            @{
                MemberType = 'AliasProperty'
                MemberName = 'RightHandSide'
                Value      = 'y'
            }
    )

    static OperablePair() {
        $TypeName = [OperablePair].Name
        foreach ($Definition in [OperablePair]::MemberDefinitions) {
            Update-TypeData -TypeName $TypeName @Definition
        }
    }

    OperablePair() {}

    OperablePair([int]$x, [int]$y) {
        $this.x = $x
        $this.y = $y
    }

    # Math methods for the pair of values
    [int]   GetSum()        { return $this.x + $this.y }
    [int]   GetProduct()    { return $this.x * $this.y }
    [int]   GetDifference() { return $this.x - $this.y }
    [float] GetQuotient()   { return $this.x / $this.y }
    [int]   GetModulus()    { return $this.x % $this.y }
}

$pair = [OperablePair]@{ x = 8 ; RightHandSide = 3 }

"$($pair.x) % $($pair.y) = $($pair.GetModulus())"

$pair.LeftHandSide  = 3
$pair.RightHandSide = 2
"$($pair.x) x $($pair.y) = $($pair.GetProduct())"
```

### Defining calculated properties

```powershell
class Budget {
    [float[]] $Expenses
    [float[]] $Revenues

    static [hashtable[]] $MemberDefinitions = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'TotalExpenses'
            Value      = { ($this.Expenses | Measure-Object -Sum).Sum }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'TotalRevenues'
            Value      = { ($this.Revenues | Measure-Object -Sum).Sum }
        }
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'NetIncome'
            Value      = { $this.TotalRevenues - $this.TotalExpenses }
        }
    )

    static Budget() {
        $TypeName = [Budget].Name
        foreach ($Definition in [Budget]::MemberDefinitions) {
            Update-TypeData -TypeName $TypeName @Definition
        }
    }

    Budget() {}

    Budget($Expenses, $Revenues) {
        $this.Expenses = $Expenses
        $this.Revenues = $Revenues
    }
}

[Budget]::new()

[Budget]@{
    Expenses = @(2500, 1931, 3700)
    Revenues = @(2400, 2100, 4150)
}
```

### Defining properties with custom get and set logic

```powershell
class ProjectSize {
    hidden [ValidateSet(0, 1, 2, 3)] [int] $_value

    static [hashtable[]] $MemberDefinitions = @(
        @{
            MemberType  = 'ScriptProperty'
            MemberName  = 'Value'
            Value       = { $this._value } # Getter
            SecondValue = {                # Setter
                $ProposedValue = $args[0]

                if ($ProposedValue -is [string]) {
                    switch ($ProposedValue) {
                        'Small'  { $this._value = 1 ; break }
                        'Medium' { $this._value = 2 ; break }
                        'Large'  { $this._value = 3 ; break }
                        default  { throw "Unknown size '$ProposedValue'" }
                    }
                } else {
                    $this._value = $ProposedValue
                }
            }
        }
    )

    static ProjectSize() {
        $TypeName = [ProjectSize].Name
        foreach ($Definition in [ProjectSize]::MemberDefinitions) {
            Update-TypeData -TypeName $TypeName @Definition
        }
    }

    ProjectSize()              {}
    ProjectSize([int]$Size)    { $this.Value = $Size }
    ProjectSize([string]$Size) { $this.Value = $Size }

    [string] ToString() {
        $Output = switch ($this._value) {
            1       { 'Small'     }
            2       { 'Medium'    }
            3       { 'Large'     }
            default { 'Undefined' }
        }

        return $Output
    }
}

$size = [ProjectSize]::new()
"The initial size is: $($size._value), $size"

$size.Value = 1
"The defined size is: $($size._value), $size"

$Size.Value += 1
"The updated size is: $($size._value), $size"

$Size.Value = 'Large'
"The final size is:   $($size._value), $size"
```
### Example 1 - Minimal definition

```powershell
class Device {
    [string]$Brand
}

$dev = [Device]::new()
$dev.Brand = "Fabrikam, Inc."
$dev
```

### Example 2 - Class with instance members

```powershell
class Book {
    # Class properties
    [string]   $Title
    [string]   $Author
    [string]   $Synopsis
    [string]   $Publisher
    [datetime] $PublishDate
    [int]      $PageCount
    [string[]] $Tags
    # Default constructor
    Book() { $this.Init(@{}) }
    # Convenience constructor from hashtable
    Book([hashtable]$Properties) { $this.Init($Properties) }
    # Common constructor for title and author
    Book([string]$Title, [string]$Author) {
        $this.Init(@{Title = $Title; Author = $Author })
    }
    # Shared initializer method
    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
    # Method to calculate reading time as 2 minutes per page
    [timespan] GetReadingTime() {
        if ($this.PageCount -le 0) {
            throw 'Unable to determine reading time from page count.'
        }
        $Minutes = $this.PageCount * 2
        return [timespan]::new(0, $Minutes, 0)
    }
    # Method to calculate how long ago a book was published
    [timespan] GetPublishedAge() {
        if (
            $null -eq $this.PublishDate -or
            $this.PublishDate -eq [datetime]::MinValue
        ) { throw 'PublishDate not defined' }

        return (Get-Date) - $this.PublishDate
    }
    # Method to return a string representation of the book
    [string] ToString() {
        return "$($this.Title) by $($this.Author) ($($this.PublishDate.Year))"
    }
}

$Book = [Book]::new(@{
    Title       = 'The Hobbit'
    Author      = 'J.R.R. Tolkien'
    Publisher   = 'George Allen & Unwin'
    PublishDate = '1937-09-21'
    PageCount   = 310
    Tags        = @('Fantasy', 'Adventure')
})

$Book
$Time = $Book.GetReadingTime()
$Time = @($Time.Hours, 'hours and', $Time.Minutes, 'minutes') -join ' '
$Age  = [Math]::Floor($Book.GetPublishedAge().TotalDays / 365.25)

"It takes $Time to read $Book,`nwhich was published $Age years ago."
```

### Example 3 - Class with static members

```powershell
class BookList {
    # Static property to hold the list of books
    static [System.Collections.Generic.List[Book]] $Books
    # Static method to initialize the list of books. Called in the other
    # static methods to avoid needing to explicit initialize the value.
    static [void] Initialize()             { [BookList]::Initialize($false) }
    static [bool] Initialize([bool]$Force) {
        if ([BookList]::Books.Count -gt 0 -and -not $Force) {
            return $false
        }

        [BookList]::Books = [System.Collections.Generic.List[Book]]::new()

        return $true
    }
    # Ensure a book is valid for the list.
    static [void] Validate([book]$Book) {
        $Prefix = @(
            'Book validation failed: Book must be defined with the Title,'
            'Author, and PublishDate properties, but'
        ) -join ' '
        if ($null -eq $Book) { throw "$Prefix was null" }
        if ([string]::IsNullOrEmpty($Book.Title)) {
            throw "$Prefix Title wasn't defined"
        }
        if ([string]::IsNullOrEmpty($Book.Author)) {
            throw "$Prefix Author wasn't defined"
        }
        if ([datetime]::MinValue -eq $Book.PublishDate) {
            throw "$Prefix PublishDate wasn't defined"
        }
    }
    # Static methods to manage the list of books.
    # Add a book if it's not already in the list.
    static [void] Add([Book]$Book) {
        [BookList]::Initialize()
        [BookList]::Validate($Book)
        if ([BookList]::Books.Contains($Book)) {
            throw "Book '$Book' already in list"
        }

        $FindPredicate = {
            param([Book]$b)

            $b.Title -eq $Book.Title -and
            $b.Author -eq $Book.Author -and
            $b.PublishDate -eq $Book.PublishDate
        }.GetNewClosure()
        if ([BookList]::Books.Find($FindPredicate)) {
            throw "Book '$Book' already in list"
        }

        [BookList]::Books.Add($Book)
    }
    # Clear the list of books.
    static [void] Clear() {
      [BookList]::Initialize()
      [BookList]::Books.Clear()
    }
    # Find a specific book using a filtering scriptblock.
    static [Book] Find([scriptblock]$Predicate) {
        [BookList]::Initialize()
        return [BookList]::Books.Find($Predicate)
    }
    # Find every book matching the filtering scriptblock.
    static [Book[]] FindAll([scriptblock]$Predicate) {
        [BookList]::Initialize()
        return [BookList]::Books.FindAll($Predicate)
    }
    # Remove a specific book.
    static [void] Remove([Book]$Book) {
        [BookList]::Initialize()
        [BookList]::Books.Remove($Book)
    }
    # Remove a book by property value.
    static [void] RemoveBy([string]$Property, [string]$Value) {
        [BookList]::Initialize()
        $Index = [BookList]::Books.FindIndex({
            param($b)
            $b.$Property -eq $Value
        }.GetNewClosure())
        if ($Index -ge 0) {
            [BookList]::Books.RemoveAt($Index)
        }
    }
}

$null -eq [BookList]::Books

[BookList]::Add($Book)

[BookList]::Books

[BookList]::Add([Book]::new(@{
    Title       = 'The Fellowship of the Ring'
    Author      = 'J.R.R. Tolkien'
    Publisher   = 'George Allen & Unwin'
    PublishDate = '1954-07-29'
    PageCount   = 423
    Tags        = @('Fantasy', 'Adventure')
}))

[BookList]::Find({
    param ($b)

    $b.PublishDate -gt '1950-01-01'
}).Title

[BookList]::FindAll({
    param($b)

    $b.Author -match 'Tolkien'
}).Title

[BookList]::Remove($Book)
[BookList]::Books.Title

[BookList]::RemoveBy('Author', 'J.R.R. Tolkien')
"Titles: $([BookList]::Books.Title)"

[BookList]::Add($Book)
[BookList]::Add($Book)
```

### Example 4a - Class with Runspace affinity (unsafe)

```powershell
# Class definition with Runspace affinity (default behavior)
class UnsafeClass {
    static [Object] ShowRunspaceId($Val) {
        return [pscustomobject]@{
            ThreadId   = [Threading.Thread]::CurrentThread.ManagedThreadId
            RunspaceId = [runspace]::DefaultRunspace.Id
        }
    }
}

$unsafe = [UnsafeClass]::new()

while ($true) {
    1..10 | ForEach-Object -Parallel {
        Start-Sleep -ms 100
        ($Using:unsafe)::ShowRunspaceId($_)
    }
}
```

### Example 4b - Class with NoRunspaceAffinity (safe)

```powershell
# Class definition with NoRunspaceAffinity attribute
[NoRunspaceAffinity()]
class SafeClass {
    static [Object] ShowRunspaceId($Val) {
        return [pscustomobject]@{
            ThreadId   = [Threading.Thread]::CurrentThread.ManagedThreadId
            RunspaceId = [runspace]::DefaultRunspace.Id
        }
    }
}

$safe = [SafeClass]::new()

while ($true) {
    1..10 | ForEach-Object -Parallel {
        Start-Sleep -ms 100
        ($Using:safe)::ShowRunspaceId($_)
    }
}
```

### Export classes with type accelerators

```powershell
# Define the types to export with type accelerators.
$ExportableTypes =@(
    [DefinedTypeName]
)
# Get the internal TypeAccelerators class to use its static methods.
$TypeAcceleratorsClass = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
foreach ($Type in $ExportableTypes) {
    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        $Message = @(
            "Unable to register type accelerator '$($Type.FullName)'"
            'Accelerator already exists.'
        ) -join ' - '

        throw [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new($Message),
            'TypeAcceleratorAlreadyExists',
            [System.Management.Automation.ErrorCategory]::InvalidOperation,
            $Type.FullName
        )
    }
}
# Add type accelerators for every exportable type.
foreach ($Type in $ExportableTypes) {
    $TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach($Type in $ExportableTypes) {
        $TypeAcceleratorsClass::Remove($Type.FullName)
    }
}.GetNewClosure()
```
### Using module-qualified names

```powershell
New-Alias -Name "Get-Date" -Value "Get-ChildItem"
Microsoft.PowerShell.Utility\Get-Date
```

### Running a command from a specific module

```powershell
MapFunctions\New-Map
```

### Finding the module source

```powershell
(Get-Command Get-Date).ModuleName

Microsoft.PowerShell.Utility
```

### Running a hidden command with call operator

```powershell
& (Get-Command -Name Map -CommandType Function)

# or

& (dir Function:\map)
```

### Saving hidden command to variable and running it

```powershell
$myMap = (Get-Command -Name map -CommandType Function)
& ($myMap)
```

### Avoiding name conflicts with Import-Module prefix

```powershell
Import-Module -Name DateFunctions -Prefix ZZ
```
### Getting syntax for a command with Get-Command

```powershell
Get-Command Get-Command -Syntax
```

### Getting parameter sets from a cmdlet

```powershell
$cmd = Get-Command Get-Random
$cmd.ParameterSets |
    Select-Object Name, IsDefault, @{n='Parameters';e={$_.ToString()}} |
    Format-Table -Wrap
```

### Using positional parameters with New-Alias

```powershell
New-Alias [-Name] <string> [-Value] <string>

# Positional syntax (parameter names optional)
New-Alias MyAlias mycommand.exe

# Named syntax
New-Alias -Name MyAlias -Value mycommand.exe
```

### Using single-value parameters

```powershell
New-Alias [-Name] <string> [-Value] <string>

New-Alias -Name MyAlias -Value mycommand.exe
```

### Using multi-value parameters

```powershell
Get-Process [-Name] <string[]>

Get-Process -Name Explorer, Winlogon, Services
```

### Using switch parameters

```powershell
Get-Command [-ListImported]
```

### Using enumeration parameters

```powershell
New-Alias -Option {None | ReadOnly | Constant | Private | AllScope}

New-Alias -Option ReadOnly
```
### Comment-based Help for a Function

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

### Parameter Descriptions in Function Syntax

```powershell
function Add-Extension
{
param
(

[string]
#Specifies the file name.
$Name,

[string]
#Specifies the file name extension. "Txt" is the default.
$Extension = "txt"
)

$Name = $Name + "." + $Extension
$Name

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

.LINK

Set-Item
#>
}
```

### Comment-based Help for a Script

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
```

### Redirecting to an XML File

```powershell
# .EXTERNALHELP C:\MyScripts\Update-Month-Help.xml

param ([string]$InputPath, [string]$OutputPath)
function Get-Data { }
```

### Redirecting to an XML File - Function Examples

```powershell
function Add-Extension {
    # .EXTERNALHELP C:\ps-test\Add-Extension.xml

    param ([string] $Name, [string]$Extension = "txt")
    $Name = $Name + "." + $Extension
    $Name
}

function Add-Extension {
    param ([string] $Name, [string]$Extension = "txt")
    $Name = $Name + "." + $Extension
    $Name

    # .EXTERNALHELP C:\ps-test\Add-Extension.xml
}

# .EXTERNALHELP C:\ps-test\Add-Extension.xml
function Add-Extension {
    param ([string] $Name, [string]$Extension = "txt")
    $Name = $Name + "." + $Extension
    $Name
}
```

### Redirecting to a Different Help Topic

```powershell
function help {
    <#
    .FORWARDHELPTARGETNAME Get-Help
    .FORWARDHELPCATEGORY Cmdlet
    #>

    [CmdletBinding(DefaultParameterSetName='AllUsersView')]
    param(
        [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
        [System.String]
        ${Name},
    ...
}
```
### Single-line comment

```powershell
# This is a single-line comment.
# This is also a single-line comment.
```

### Block comment

```powershell
<#
    This is a block comment.
    Text within the block is a part of the same comment.
Whitespace is unimportant in a block comment.
#>
```

### End-of-line comment

```powershell
$var = 4 # This is an end-of-line comment
```

### Inline block comment

```powershell
'Foo'; <# This is an inline block comment #> 'Bar'
```

### Full example demonstrating different comment styles

```powershell
<#
    .DESCRIPTION
    Demonstrates PowerShell's different comment styles.
#>
param (
    [string] $Param1, # End-of-line comment
    <# Inline block comment #> $Param2
)

$var = 1, <# Inline block comment #> 2, 2

# Single-line comment.
# Another single-line comment.
$var.Where(
    <# Arg1 note #> { $_ -eq 2 },
    <# Arg2 note #> 'First',
    <# Arg3 note #> 1
)
```

### Comment-based help using a block comment

```powershell
<#
    .DESCRIPTION
    Comment-based help using a block comment.
#>
function Get-Function { }
```

### Comment-based help using multiple single-line comments

```powershell
# .DESCRIPTION
# Comment-based help using multiple single-line comments.
function Get-Function { }
```

### #Requires statement for modules and version

```powershell
#Requires -Modules AzureRM.Netcore
#Requires -Version 6.0

param (
    [Parameter(Mandatory)]
    [string[]] $Path
)
```

### Shebang for running script from non-PowerShell context

```powershell
#!/usr/bin/env pwsh
Write-Host 'Begin script'
```

### Comments in expandable string (not interpreted)

```powershell
PS> '# This is not interpreted as a comment.'
# This is not interpreted as a comment.
```

### Comments in verbatim string (not interpreted)

```powershell
PS> "This is <# also not interpreted #> as a comment."
This is <# also not interpreted #> as a comment.
```

### Inline regex comment

```powershell
PS> 'book' -match '(?# This is an inline comment)oo'
True
```

### End-of-line regex comment with (?x) construct

```powershell
PS> 'book' -match '(?x)oo# This is an end-of-line comment'
True
```

### End-of-line regex comment with IgnorePatternWhitespace option

```powershell
PS> $regex = 'oo # This is an end-of-line comment'
PS> 'book' -split $regex, 0, 'IgnorePatternWhitespace'
b
k
```

### JSON with single-line comment deserialized by ConvertFrom-Json

```powershell
'{
        "Foo": "Bar" // This is a single-line comment
    }' | ConvertFrom-Json

Foo
---
Bar
```

### CSV with comment (ignored by ConvertFrom-Csv)

```powershell
@'
# This is a CSV comment
Col1,Col2
Val1,Val2
'@ | ConvertFrom-Csv

Col1 Col2
---- ----
Val1 Val2
```

### Export-Csv with -IncludeTypeInformation

```powershell
[pscustomobject] @{ Foo = 'Bar' } | ConvertTo-Csv -IncludeTypeInformation

#TYPE System.Management.Automation.PSCustomObject
"Foo"
"Bar"
```

### Import-Csv/ConvertFrom-Csv using type information

```powershell
class Test { $Foo = 'Bar' }
$test = [Test]::new()

$var = $test | ConvertTo-Csv -IncludeTypeInformation | ConvertFrom-Csv
$var.pstypenames

Test
CSV:Test
```
### Using OutBuffer parameter with ForEach-Object

```powershell
1..4 | ForEach-Object {
            Write-Host "$($_): First"; $_
          } -OutBuffer 1 | ForEach-Object {
                            Write-Host "$($_): Second" }

1: First
2: First
1: Second
2: Second
3: First
4: First
3: Second
4: Second
```

### Storing output in a variable using OutVariable

```powershell
Get-Process powershell -OutVariable out
```

### Adding output to an existing variable using OutVariable +

```powershell
Get-Process iexplore -OutVariable +out
```

### Displaying content of variable populated by OutVariable

```powershell
$out
```

### PipelineVariable example (initial setup and output)

```powershell
# Create a variable named $Temp
$Temp = 8
Get-Variable Temp | Format-Table

$InformationPreference = 'Continue'
Write-Information '-------------------------------------------------'
111,222,333,444,555 | ForEach-Object -PipelineVariable Temp -Begin {

      # Note that the newly create $Temp variable doesn't contain the value 8
      # assigned before the pipeline started and that $PSItem is empty in
      # the Begin block.
      Write-Information "Upstream (Begin):   PSItem = '$PSItem', Temp = '$Temp'"

    } -Process {

      Write-Information "Upstream (Process): PSItem = '$PSItem', Temp = '$Temp'"
      return $PSItem

    } | ForEach-Object -Process {

      Write-Information "\tDownstream: PSItem = '$PSItem', Temp = '$Temp'"

    }
Write-Information '-------------------------------------------------'

# The $Temp variable is deleted when the pipeline finishes
Get-Variable Temp | Format-Table

Name                           Value
----                           -----
Temp                           8

-------------------------------------------------
Upstream (Begin):   PSItem = '', Temp = ''
Upstream (Process): PSItem = '111', Temp = ''
        Downstream: PSItem = '111', Temp = '111'
Upstream (Process): PSItem = '222', Temp = '111'
        Downstream: PSItem = '222', Temp = '222'
Upstream (Process): PSItem = '333', Temp = '222'
        Downstream: PSItem = '333', Temp = '333'
Upstream (Process): PSItem = '444', Temp = '333'
        Downstream: PSItem = '444', Temp = '444'
Upstream (Process): PSItem = '555', Temp = '444'
        Downstream: PSItem = '555', Temp = '555'
-------------------------------------------------

Name                           Value
----                           -----
Temp
```

### PipelineVariable issue with CDXML functions

```powershell
Get-Partition -pv pvar
```

### PipelineVariable issue with CimCmdlets (pvar remains last accumulated object)

```powershell
Get-CimInstance Win32_DiskDrive -pv pvar |
    ForEach-Object {
        Write-Host "Upstream: Disk $($pvar.Index)"
        return [pscustomobject]@{ DiskNumber = $_.Index }
    } | Get-Partition | ForEach-Object {
        Write-Host "Downstream: Disk $($pvar.Index)"
    }
```

### Using WhatIf parameter with Remove-Item

```powershell
Remove-Item Date.csv -WhatIf
```

### Using Confirm parameter with Remove-Item

```powershell
PS C:\ps-test> Remove-Item tmp*.txt -Confirm

Confirm
Are you sure you want to perform this action?
Performing operation "Remove File" on Target " C:\ps-test\tmp1.txt
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend
[?] Help (default is "Y"):
```

### Using Suspend option with Confirm parameter

```powershell
PS C:\ps-test> New-Item -ItemType File -Name Test.txt -Confirm

Confirm
Are you sure you want to perform this action?

Performing operation "Create File" on Target "Destination:
C:\ps-test\test.txt".
[Y] Yes [A] Yes to All [N] No [L] No to All [S] Suspend [?] Help (default
is "Y"): s

PS C:\ps-test> Get-Help New-Item -Parameter ItemType

-ItemType <string>
Specifies the provider-specified type of the new item.

Required?                    false
Position?                    named
Default value
Accept pipeline input?       true (ByPropertyName)
Accept wildcard characters?  false

PS C:\ps-test> exit

Confirm
Are you sure you want to perform this action?
Performing operation "Create File" on Target "Destination: C:\ps-test\test
.txt".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (defau
lt is "Y"): y

Directory: C:\ps-test

Mode                LastWriteTime     Length Name
----                -------------     ------ ----
-a---         8/27/2010   2:41 PM          0 test.txt
```
### Equality operators - Basic examples

```powershell
2 -eq 2                 # Output: True
2 -eq 3                 # Output: False
'abc' -eq 'abc'         # Output: True
'abc' -eq 'abc', 'def'  # Output: False
'abc' -ne 'def'         # Output: True
'abc' -ne 'abc'         # Output: False
'abc' -ne 'abc', 'def'  # Output: True
```

### Equality operators - Collection examples

```powershell
1,2,3 -eq 2             # Output: 2
'abc', 'def' -eq 'abc'  # Output: abc
'abc', 'def' -ne 'abc'  # Output: def
```

### Equality operators - Processing all elements

```powershell
'zzz', 'def', 'zzz' -eq 'zzz'

# Output:
# zzz
# zzz
```

### Equality operators - Type conversion

```powershell
PS> 1 -eq '1.0'
True

PS> '1.0' -eq 1
False
```

### Equality operators - Custom class comparison

```powershell
class MyFileInfoSet {
    [string]$File
    [int64]$Size
}
$a = [MyFileInfoSet]@{File = 'C:\Windows\explorer.exe'; Size = 4651032}
$b = [MyFileInfoSet]@{File = 'C:\Windows\explorer.exe'; Size = 4651032}
$a -eq $b

# Output: False
```

### Equality operators - Implementing IEquatable

```powershell
class MyFileInfoSet : System.IEquatable[Object] {
    [string]$File
    [int64]$Size

    [bool] Equals([Object] $obj) {
        return ($this.File -eq $obj.File) -and ($this.Size -eq $obj.Size)
    }
}
$a = [MyFileInfoSet]@{File = 'C:\Windows\explorer.exe'; Size = 4651032}
$b = [MyFileInfoSet]@{File = 'C:\Windows\explorer.exe'; Size = 4651032}
$a -eq $b

# Output: True
```

### Equality operators - Null handling

```powershell
$a = 1, 2, $null, 4, $null, 6

$null -ne $a

# Output: True

$a -ne $null # Output: 1, 2, 4, 6

# Output:
# 1
# 2
# 4
# 6
```

### Greater than/less than operators - Scalar examples

```powershell
8 -gt 6  # Output: True
8 -ge 8  # Output: True
6 -lt 8  # Output: True
8 -le 8  # Output: True
```

### Greater than/less than operators - Collection examples

```powershell
$a=5, 6, 7, 8, 9

Write-Output 'Test collection:'
$a

Write-Output "`nMembers greater than 7"
$a -gt 7

Write-Output "`nMembers greater than or equal to 7"
$a -ge 7

Write-Output "`nMembers smaller than 7"
$a -lt 7

Write-Output "`nMembers smaller than or equal to 7"
$a -le 7
```

### Greater than/less than operators - Type comparison

```powershell
# Date comparison
[datetime]'2001-11-12' -lt [datetime]'2020-08-01' # True

# Sorting order comparison
'a' -lt 'z'           # True; 'a' comes before 'z'
'macOS' -ilt 'MacOS'  # False
'MacOS' -ilt 'macOS'  # False
'macOS' -clt 'MacOS'  # True; 'm' comes before 'M'
```

### Greater than/less than operators - Symbol comparison

```powershell
$a=' ','`','~','!','@','#','$','%','^','&','*','(',')','_','+','-','=',
   '{','}','[',']',':',';','"','''','\','|','/','?','..','>',',','<'
$a -gt 'a'
# Output: Nothing
```

### Wildcard matching - Basic examples

```powershell
'PowerShell' -like    '*shell'           # Output: True
'PowerShell' -notlike '*shell'           # Output: False
'PowerShell' -like    'Power?hell'       # Output: True
'PowerShell' -notlike 'Power?hell'       # Output: False
'PowerShell' -like    'Power[p-w]hell'   # Output: True
'PowerShell' -notlike 'Power[p-w]hell'   # Output: False

'PowerShell', 'Server' -like '*shell'    # Output: PowerShell
'PowerShell', 'Server' -notlike '*shell' # Output: Server
```

### Wildcard matching - Escape characters

```powershell
# Escaped literals in an expandable string
PS> "f`?`?"
f??
# Escaped literals in a literal string
PS> 'f`?`?'
f`?`?
# Comparison containing 2 wildcards
PS> 'f??' -like 'f??'
True
PS> 'for' -like 'f??'
True
# Comparison containing literal '?' characters
PS> 'f??' -like 'f`?`?'
True
PS> 'for' -like 'f`?`?'
False
```

### Regex matching - Scalar examples

```powershell
# Partial match test, showing how differently -match and -like behave
'PowerShell' -match 'shell'        # Output: True
'PowerShell' -like  'shell'        # Output: False

# Regex syntax test
'PowerShell' -match    '^Power\w+' # Output: True
'bag'        -notmatch 'b[iou]g'   # Output: True
```

### Regex matching - Collection examples

```powershell
'PowerShell', 'Super PowerShell', 'Power's hell' -match '^Power\w+'
# Output: PowerShell

'Rhell', 'Chell', 'Mel', 'Smell', 'Shell' -match 'hell'
# Output: Rhell, Chell, Shell

'Bag', 'Beg', 'Big', 'Bog', 'Bug'  -match 'b[iou]g'
#Output: Big, Bog, Bug

'Bag', 'Beg', 'Big', 'Bog', 'Bug'  -notmatch 'b[iou]g'
#Output: Bag, Beg
```

### Regex matching - Capture groups

```powershell
$string = 'The last logged on user was CONTOSO\jsmith'
$string -match 'was (?<domain>.+)\\(?<user>.+)'

$Matches

Write-Output "`nDomain name:"
$Matches.domain

Write-Output "`nUser name:"
$Matches.user
```

### Regex matching - Conditional verification

```powershell
if ('<version>1.0.0</version>' -match '<version>(.*?)</version>') {
    $Matches
}
```

### Replace operator - Basic example

```powershell
Get-ChildItem *.txt | Rename-Item -NewName { $_.Name -replace '\.txt$','.log' }
```

### Replace operator - Case sensitivity

```powershell
'book' -ireplace 'B', 'C' # Case insensitive
'book' -creplace 'B', 'C' # Case-sensitive; hence, nothing to replace

# Output:
# Cook
# book
```

### Replace operator - Culture handling

```powershell
# Prior to PowerShell 7.2:
PS> [cultureinfo]::CurrentCulture = 'fr'
PS> 1.2 -replace ','
12

# In PowerShell 7.2 and later:
PS> [cultureinfo]::CurrentCulture = 'fr'
PS> 1.2 -replace ','
1.2
```

### Replace operator - Regex substitutions with capture groups

```powershell
$SearchExp = '^(?<DomainName>[\w-.]+)\\(?<Username>[\w-.]+)$'
$ReplaceExp = '${Username}@${DomainName}'

'Contoso.local\John.Doe' -replace $SearchExp, $ReplaceExp

# Output: John.Doe@Contoso.local
```

### Replace operator - Dollar sign handling

```powershell
$1 = 'Goodbye'

'Hello World' -replace '(\w+) \w+', "$1 Universe"
# Output: Goodbye Universe

'Hello World' -replace '(\w+) \w+', '$1 Universe'
# Output: Hello Universe
```

### Replace operator - Literal dollar signs

```powershell
'5.72' -replace '(.+)', '$ $1' # Output: $ 5.72
'5.72' -replace '(.+)', '$$$1' # Output: $5.72
'5.72' -replace '(.+)', '$$1'  # Output: $1
```

### Replace operator - Collection replacement

```powershell
'B1','B2','B3','B4','B5' -replace 'B', 'a'
# Output:
# a1
# a2
# a3
# a4
# a5
```

### Replace operator - Script block replacement

```powershell
'072101108108111' -replace '\d{3}', {return [char][int]$_.Value}

# Output: Hello
```

### Containment operators - Contains/NotContains

```powershell
'abc', 'def' -contains 'def'                  # Output: True
'abc', 'def' -notcontains 'def'               # Output: False
'Windows', 'PowerShell' -contains 'Shell'     # Output: False
'Windows', 'PowerShell' -notcontains 'Shell'  # Output: True
'abc', 'def', 'ghi' -contains 'abc', 'def'    # Output: False
'abc', 'def', 'ghi' -notcontains 'abc', 'def' # Output: True
```

### Containment operators - Complex contains example

```powershell
$DomainServers = 'ContosoDC1', 'ContosoDC2', 'ContosoFileServer',
                 'ContosoDNS', 'ContosoDHCP', 'ContosoWSUS'
$thisComputer  = 'ContosoDC2'

$DomainServers -contains $thisComputer
# Output: True
```

### Containment operators - In/NotIn

```powershell
'def' -in 'abc', 'def'                  # Output: True
'def' -notin 'abc', 'def'               # Output: False
'Shell' -in 'Windows', 'PowerShell'     # Output: False
'Shell' -notin 'Windows', 'PowerShell'  # Output: True
'abc', 'def' -in 'abc', 'def', 'ghi'    # Output: False
'abc', 'def' -notin 'abc', 'def', 'ghi' # Output: True
```

### Containment operators - Complex In example

```powershell
$DomainServers = 'ContosoDC1', 'ContosoDC2', 'ContosoFileServer',
                 'ContosoDNS', 'ContosoDHCP', 'ContosoWSUS'
$thisComputer  = 'ContosoDC2'

$thisComputer -in $DomainServers
# Output: True
```

### Type comparison operators

```powershell
$a = 1
$b = '1'
$a -is [int]           # Output: True
$a -is $b.GetType()    # Output: False
$b -isnot [int]        # Output: True
$a -isnot $b.GetType() # Output: True
```
### Using continue in loops - While loop example

```powershell
while ($ctr -lt 10)
{
    $ctr += 1
    if ($ctr -eq 5)
    {
        continue
    }

    Write-Host -Object $ctr
}
```

### Using continue in loops - For loop example

```powershell
#   <Init>  <Condition> <Repeat>
for ($i = 0; $i -lt 10; $i++)
{
    Write-Host -Object $i
    if ($i -eq 5)
    {
        continue
        # Will not result in an infinite loop.
        $i--
    }
}
```

### Using a labeled continue in a loop

```powershell
:labelA for ($i = 1; $i -le 10; $i++) {
    :labelB for ($j = 1; $j -le 10; $j++) {
        :labelC for ($k = 1; $k -le 10; $k++) {
            if ($condition) {
                continue labelB
            } else {
                $condition = Update-Condition
            }
        }
    }
}
```

### Using continue in a switch statement

```powershell
switch (1,2,3) {
  2 { continue }  # moves on to the next element, 3
  default { $_ }
}

# Output:
# 1
# 3
```
### Using a data section with ConvertFrom-StringData

```powershell
$TextMsgs = data {
    ConvertFrom-StringData -StringData @'
Text001 = Windows 7
Text002 = Windows Server 2008 R2
'@
}

$TextMsgs.Text001
$TextMsgs.Text002
```

### Data section with variable name

```powershell
data TextMsgs {
    ConvertFrom-StringData -StringData @'
Text001 = Windows 7
Text002 = Windows Server 2008 R2
'@
}

$TextMsgs
```

### Simple data strings

```powershell
data {
    "Thank you for using my PowerShell Organize.pst script."
    "It is provided free of charge to the community."
    "I appreciate your comments and feedback."
}
```

### Strings that include permitted variables

```powershell
data {
    if ($null) {
        "To get help for this cmdlet, type Get-Help New-Dictionary."
    }
}
```

### Single-quoted here-string with ConvertFrom-StringData

```powershell
data {
    ConvertFrom-StringData -StringData @'
Text001 = Windows 7
Text002 = Windows Server 2008 R2
'@
}
```

### Double-quoted here-string with ConvertFrom-StringData

```powershell
data {
    ConvertFrom-StringData -StringData @"
Msg1 = To start, press any key.
Msg2 = To exit, type "quit".
"@
}
```

### Data section with SupportedCommand parameter

```powershell
data -SupportedCommand Format-Xml {
    Format-Xml -Strings string1, string2, string3
}
```
### Displaying test script content

```powershell
PS C:\PS-test>  Get-Content test.ps1

function psversion {
  "PowerShell " + $PSVersionTable.PSVersion
  if ($PSVersionTable.PSVersion.Major -lt 7) {
    "Upgrade to PowerShell 7!"
  }
  else {
    "Have you run a background job today (Start-Job)?"
  }
}

$scriptName = $MyInvocation.PSCommandPath
psversion
"Done $scriptName."
```

### Setting a line breakpoint on the first line of test.ps1

```powershell
PS C:\ps-test> Set-PSBreakpoint -Line 1 -Script test.ps1
```

### Output of Set-PSBreakpoint (LineBreakpoint object)

```powershell
Column     : 0
Line       : 1
Action     :
Enabled    : True
HitCount   : 0
Id         : 0
Script     : C:\ps-test\test.ps1
ScriptName : C:\ps-test\test.ps1
```

### Starting the script with a breakpoint

```powershell
PS C:\ps-test> .\test.ps1
```

### Debugger output on hitting the first breakpoint

```powershell
Entering debug mode. Use h or ? for help.

Hit Line breakpoint on 'C:\ps-test\test.ps1:1'

test.ps1:1   function psversion {
DBG> 
```

### Using 's' (StepInto) to execute a statement

```powershell
DBG> s
test.ps1:11  $scriptName = $MyInvocation.PSCommandPath
```

### Displaying the unpopulated $scriptName variable

```powershell
DBG> $scriptname
DBG> 
```

### Using 's' (StepInto) again to preview function call

```powershell
DBG> s
test.ps1:12  psversion
```

### Displaying the populated $scriptName variable

```powershell
DBG> $scriptName
C:\ps-test\test.ps1
```

### Using 's' (StepInto) to execute function call

```powershell
DBG> s
test.ps1:2       "PowerShell " + $PSVersionTable.PSVersion
```

### Using 'o' (StepOut) to complete function execution

```powershell
DBG> o
Windows PowerShell 2.0
Have you run a background job today (Start-Job)?
test.ps1:13  "Done $scriptName"
```

### Using 'o' (StepOut) for the last statement

```powershell
Done C:\ps-test\test.ps1
PS C:\ps-test> 
```

### Deleting all breakpoints

```powershell
PS C:\ps-test> Get-PSBreakpoint | Remove-PSBreakpoint
```

### Abbreviated command to delete all breakpoints

```powershell
PS C:\ps-test> gbp | rbp
```

### Function to delete breakpoints

```powershell
function delbr { gbp | rbp }
```

### Creating a variable breakpoint

```powershell
PS C:\ps-test> Set-PSBreakpoint -Variable scriptname -Script test.ps1
```

### Abbreviated command to create a variable breakpoint

```powershell
PS C:\ps-test> sbp -V scriptname -S test.ps1
```

### Hitting a variable breakpoint (write access)

```powershell
PS C:\ps-test> .\test.ps1
Hit Variable breakpoint on 'C:\ps-test\test.ps1:$scriptName'
(Write access)

test.ps1:11  $scriptName = $MyInvocation.PSCommandPath
DBG> 
```

### Displaying $scriptName before population

```powershell
DBG> $scriptname
DBG> 
```

### Displaying $scriptName after population

```powershell
DBG> $scriptname
C:\ps-test\test.ps1
```

### Using 's' (StepInto) to preview function call with variable breakpoint

```powershell
DBG> s
test.ps1:12  psversion
```

### Using 'v' (StepOver) to execute function call with variable breakpoint

```powershell
DBG> v
Windows PowerShell 2.0
Have you run a background job today (Start-Job)?
test.ps1:13  "Done $scriptName"
```

### Using 't' (Stop) to exit debugger

```powershell
C:\ps-test> 
```

### Deleting breakpoints after debugging session

```powershell
PS C:\ps-test> Get-PSBreakpoint | Remove-PSBreakpoint
```

### Creating a command breakpoint on psversion function

```powershell
PS C:\ps-test> Set-PSBreakpoint -Command psversion -Script test.ps1
```

### Abbreviated command to create a command breakpoint

```powershell
PS C:\ps-test> sbp -C psversion -S test.ps1
```

### Running script with command breakpoint (before function call)

```powershell
PS C:\ps-test> .\test.ps1
Hit Command breakpoint on 'C:\ps-test\test.ps1:psversion'

test.ps1:12  psversion
DBG> 
```

### Using 'c' (Continue) to exit debugger after command breakpoint

```powershell
DBG> c
Windows PowerShell 2.0
Have you run a background job today (Start-Job)?
Done C:\ps-test\test.ps1

PS C:\ps-test> Get-PSBreakpoint | Remove-PSBreakpoint
PS C:\ps-test> 
```

### Setting command breakpoint with Action logging $scriptName

```powershell
PS C:\ps-test> Set-PSBreakpoint -Command psversion -Script test.ps1  `
-Action { Add-Content "The value of `$scriptName is $scriptName." `
-Path action.log}
```

### Setting command breakpoint with Action conditionally breaking based on ExecutionPolicy

```powershell
PS C:\ps-test> Set-PSBreakpoint -Script test.ps1 -Command psversion `
-Action { if ((Get-ExecutionPolicy) -eq "RemoteSigned") { break }}
```

### Running script with conditional command breakpoint (execution stops)

```powershell
PS C:\ps-test> .\test.ps1
Hit Command breakpoint on 'C:\ps-test\test.ps1:psversion'

test.ps1:12  psversion
```

### Checking call stack in debugger

```powershell
DBG> k
2: prompt
1: .\test.ps1: $args=[]
0: prompt: $args=[]
```
### Do-While loop counting array items

```powershell
PS> $x = 1,2,78,0
PS> do { $count++; $a++; } while ($x[$a] -ne 0)
PS> $count
3
```

### Do-Until loop counting array items

```powershell
PS> $x = 1,2,78,0
PS> do { $count++; $a++; } until ($x[$a] -eq 0)
PS> $count
3
```

### Do-While loop writing array values with continue

```powershell
do {
  if ($x[$a] -lt 0) { continue }
  Write-Host $x[$a]
}
while (++$a -lt 10)
```
### Example 1 - Minimal enumeration

```powershell
enum MarkdownUnorderedListCharacter {
    Asterisk
    Dash
    Plus
}

$ValuesToConvert = @(0, 'Asterisk', 1, 'Dash', 2, 'Plus')
foreach ($Value in $ValuesToConvert) {
    [MarkdownUnorderedListCharacter]$EnumValue = $Value

    [pscustomobject]@{
        AssignedValue = $Value
        Enumeration   = $EnumValue
        AreEqual      = $Value -eq $EnumValue
    }
}
```

### Example 2 - Explicit and synonym enumeration values

```powershell
enum MediaTypes {
    unknown
    music   = 10
    mp3
    aac
    ogg     = 15
    oga     = 15
    mogg    = 15
    picture = 20
    jpg
    jpeg    = 21
    png
    video   = 40
    mpg
    mpeg    = 41
    avi
    m4v
}

[MediaTypes].GetEnumNames()

[MediaTypes].GetEnumValues()

[MediaTypes].GetEnumName(15)

[MediaTypes].GetEnumNames() | ForEach-Object {
  [pscustomobject]@{
    Name = $_
    Value = [int]([MediaTypes]::$_)
  }
}

[MediaTypes]::png
[MediaTypes]::png -eq 22
```

### Example 3 - Enumeration as flags

```powershell
[Flags()] enum FileAttributes {
    Archive    = 1
    Compressed = 2
    Device     = 4
    Directory  = 8
    Encrypted  = 16
    Hidden     = 32
}

[FileAttributes]$file1 =  [FileAttributes]::Archive
[FileAttributes]$file1 += [FileAttributes]::Compressed
[FileAttributes]$file1 += [FileAttributes]::Device
"file1 attributes are: $file1"

[FileAttributes]$file2 = [FileAttributes]28 ## => 16 + 8 + 4
"file2 attributes are: $file2"

($file2 -band [FileAttributes]::Device) -eq [FileAttributes]::Device
($file2 -band [FileAttributes]::Archive) -eq [FileAttributes]::Archive

$file1.HasFlag([FileAttributes]::Device)
$file1.HasFlag([FileAttributes]::Hidden)
```

### Example 4 - Enumeration as a parameter

```powershell
enum EndOfLine {
    CR   = 1
    LF   = 2
    CRLF = 3
}

function ConvertTo-LineEndingRegex {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [EndOfLine[]]$InputObject
    )

    process {
        switch ($InputObject) {
            CR   {  '\r'  }
            LF   {  '\n'  }
            CRLF { '\r\n' }
        }
    }
}

[EndOfLine]::CR | ConvertTo-LineEndingRegex
'CRLF' | ConvertTo-LineEndingRegex
ConvertTo-LineEndingRegex 2
```

### Example 5 - Enumerations with specific underlying types

```powershell
$EnumTypes     = @()
$IntegralTypes = @(
    'byte', 'sbyte', 'short', 'ushort', 'int', 'uint', 'long', 'ulong'
)

$DefinitionTemplate = @"
enum {0}Enum : {0} {{
    Min = [{0}]::MinValue
    Max = [{0}]::MaxValue
}}

[{0}Enum]
"@

foreach ($IntegralType in $IntegralTypes) {
    $Definition  = $DefinitionTemplate -f $IntegralType
    $ScriptBlock = [scriptblock]::Create($Definition)
    $EnumTypes  += . $ScriptBlock
}

foreach ($EnumType in $EnumTypes) {
    $EnumType.GetEnumValuesAsUnderlyingType() | ForEach-Object {
        [pscustomobject]@{
            EnumType  = $EnumType.FullName
            ValueType = $_.GetType().FullName
            Label     = $EnumType.GetEnumName($_)
            Value     = $_
        }
    }
}
```

### Format method - TaskState enumeration

```powershell
enum TaskState {
    ToDo
    Doing
    Done
}

$Statement = "[System.Enum]::Format([TaskState], {0}, '{1}')"

foreach ($Format in @('G', 'D', 'X', 'F')) {
    $StatementToDo  = $Statement -f 0, $Format
    $StatementDoing = $Statement -f "([TaskState]'Doing')", $Format
    $StatementDone  = $Statement -f '[TaskState]::Done', $Format
    $FormattedToDo  = [System.Enum]::Format(
      [TaskState], 0, $Format
    )
    $FormattedDoing = [System.Enum]::Format(
        [TaskState], ([TaskState]'Doing'), $Format
    )
    $FormattedDone  = [System.Enum]::Format(
      [TaskState], [TaskState]::Done, $Format
    )

    "{0,-62} => {1}" -f $StatementToDo,  $FormattedToDo
    "{0,-62} => {1}" -f $StatementDoing, $FormattedDoing
    "{0,-62} => {1}" -f $StatementDone,  $FormattedDone
}
```

### GetEnumName method

```powershell
enum GateState {
    Unknown
    Open
    Opening
    Closing
    Closed
}

foreach ($Value in 0..4) {
    [pscustomobject]@{
      IntegerValue = $Value
      EnumName     = [GateState].GetEnumName($Value)
    }
}
```

### GetEnumNames method

```powershell
enum Season {
    Unknown
    Spring
    Summer
    Autumn
    Winter
    Fall   = 3
}

[Season].GetEnumNames()
```

### GetEnumUnderlyingType method

```powershell
enum IntBasedEnum {
    Zero
    One
    Two
}
enum ShortBasedEnum : short {
    Zero
    One
    Two
}

foreach ($EnumType in @([IntBasedEnum], [ShortBasedEnum])) {
    [pscustomobject]@{
        EnumType = $EnumType
        ValueType = $EnumType.GetEnumUnderlyingType()
    }
}
```

### GetEnumValues method

```powershell
enum Season {
    Unknown
    Spring
    Summer
    Autumn
    Winter
    Fall   = 3
}

[Season].GetEnumValues()
```

### GetEnumValuesAsUnderlyingType method

```powershell
enum IntBasedEnum {
    Zero
    One
    Two
}
enum ShortBasedEnum : short {
    Zero
    One
    Two
}

foreach ($EnumType in @([IntBasedEnum], [ShortBasedEnum])) {
    [pscustomobject]@{
        EnumType = $EnumType
        ValueType = $EnumType.GetEnumValuesAsUnderlyingType()[0].GetType()
    }
}
```

### HasFlag method

```powershell
[Flags()] enum ModuleFeatures {
    Commands  = 1
    Classes   = 2
    Enums     = 4
    Types     = 8
    Formats   = 16
    Variables = 32
}

$Features = [ModuleFeatures]39

foreach ($Feature in [ModuleFeatures].GetEnumValues()) {
    "Has flag {0,-12}: {1}" -f "'$Feature'", ($Features.HasFlag($Feature))
}
```

### IsDefined method

```powershell
enum Season {
    Unknown
    Spring
    Summer
    Autumn
    Winter
    Fall   = 3
}

foreach ($Value in 0..5) {
    $IsValid   = [Season]::IsDefined([Season], $Value)
    $EnumValue = if ($IsValid) { [Season]$Value }

    [pscustomobject] @{
        InputValue = $Value
        IsValid    = $IsValid
        EnumValue  = $EnumValue
    }
}
```

### ToString method

```powershell
enum Shade {
    White
    Grey
    Gray = 1
    Black
}

[Shade].GetEnumValues() | ForEach-Object -Process {
    [pscustomobject]@{
        EnumValue    = $_
        StringValue  = $_.ToString()
        IntegerValue = [int]$_
    }
}
```

### Enumeration value synonyms

```powershell
enum Shade {
    White
    Grey
    Gray = 1
    Black
}

[Shade]'Grey' -eq [Shade]::Gray
[Shade]::Grey -eq 1
[Shade]'Gray' -eq 1
```

### Formatting enumeration values - TaskState

```powershell
enum TaskState {
    ToDo
    Doing
    Done
}

[TaskState].GetEnumValues() | ForEach-Object {
    [pscustomobject]@{
        "ToString('G')" = $_.ToString('G')
        "ToString('D')" = $_.ToString('D')
        "ToString('X')" = $_.ToString('X')
        "ToString('F')" = $_.ToString('F')
    }
}
```

### Formatting enumeration values - Flag enumeration

```powershell
[Flags()] enum FlagEnum {
    A = 1
    B = 2
    C = 4
}

$FlagValues = @(
    [FlagEnum]::A                                 # 1
    [FlagEnum]::B                                 # 2
    [FlagEnum]::A + [FlagEnum]::B                 # 3
    [FlagEnum]::C                                 # 4
    [FlagEnum]::C + [FlagEnum]::A                 # 5
    [FlagEnum]::C + [FlagEnum]::B                 # 6
    [FlagEnum]::C + [FlagEnum]::A + [FlagEnum]::B # 7
    [FlagEnum]::C + [FlagEnum]::C                 # 8
)

foreach ($Value in $FlagValues) {
    [pscustomobject]@{
        "ToString('G')" = $Value.ToString('G')
        "ToString('D')" = $Value.ToString('D')
        "ToString('X')" = $Value.ToString('X')
        "ToString('F')" = $Value.ToString('F')
    }
}
```

### Defining extension methods with Update-TypeData

```powershell
[Flags()] enum FileAttributes {
    Archive    = 1
    Compressed = 2
    Device     = 4
    Directory  = 8
    Encrypted  = 16
    Hidden     = 32
}

$MemberDefinition = @{
    TypeName   = 'FileAttributes'
    MemberName = 'GetFlags'
    MemberType = 'ScriptMethod'
    Value      = {
        foreach ($Flag in $this.GetType().GetEnumValues()) {
          if ($this.HasFlag($Flag)) { $Flag }
        }
    }
}

Update-TypeData @MemberDefinition

$File = [FileAttributes]28

$File.GetFlags()
```

### Exporting enumerations with type accelerators

```powershell
$ExportableTypes =@(
    [DefinedTypeName]
)
$TypeAcceleratorsClass = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
foreach ($Type in $ExportableTypes) {
    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        $Message = @(
            "Unable to register type accelerator '$($Type.FullName)'"
            'Accelerator already exists.'
        ) -join ' - '

        throw [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new($Message),
            'TypeAcceleratorAlreadyExists',
            [System.Management.Automation.ErrorCategory]::InvalidOperation,
            $Type.FullName
        )
    }
}
foreach ($Type in $ExportableTypes) {
    $TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach($Type in $ExportableTypes) {
        $TypeAcceleratorsClass::Remove($Type.FullName)
    }
}.GetNewClosure()
```
### Changing location to Env: drive

```powershell
Set-Location Env:
```

### Returning to a file system drive

```powershell
Set-Location C:
```

### Viewing contents of PROGRAMFILES environment variable using $Env: prefix

```powershell
PS C:\> $Env:ProgramFiles
C:\Program Files
```

### Listing all environment variables in the current session

```powershell
Get-Item -Path Env:
```

### Listing all environment variables using Get-ChildItem

```powershell
Get-ChildItem -Path Env:
```

### Get a selected environment variable (windir)

```powershell
Get-ChildItem -Path Env:windir
```

### Get environment variable using $Env: prefix

```powershell
$Env:windir
```

### Create an environment variable (USERMODE)

```powershell
PS C:\> New-Item -Path Env: -Name USERMODE -Value Non-Admin
```

### Rename an environment variable (USERMODE to USERROLE)

```powershell
Rename-Item -Path Env:USERMODE -NewName USERROLE
```

### Change an environment variable's value (USERROLE to Administrator)

```powershell
Set-Item -Path Env:USERROLE -Value Administrator
```

### Copy an environment variable (USERROLE to USERROLE2)

```powershell
Copy-Item -Path Env:USERROLE -Destination Env:USERROLE2
```

### Remove an environment variable (USERROLE2)

```powershell
Remove-Item -Path Env:USERROLE2
```

### Remove an environment variable by clearing its value (USERROLE)

```powershell
Clear-Item -Path Env:USERROLE
```

### Get customized help topics for Get-ChildItem (file system drive context)

```powershell
Get-Help Get-ChildItem
```

### Get customized help topics for Get-ChildItem (Env: drive context)

```powershell
Get-Help Get-ChildItem -Path Env:
```
### Displaying the value of the windir environment variable

```powershell
$Env:windir

C:\Windows
```

### Creating the Foo environment variable

```powershell
$Env:Foo = 'An example'
```

### Using the Foo environment variable and appending to it

```powershell
"The 'Foo' environment variable is set to: $Env:Foo"
$Env:Foo += '!'
$Env:Foo

The 'Foo' environment variable is set to: An example

An example!
```

### Setting an environment variable to an empty string (PowerShell 7.5+)

```powershell
PS> $env:TEST = ''
PS> Get-ChildItem env:TEST

Name                           Value
----
TEST
```

### Setting an environment variable to $null removes it (PowerShell 7.5+)

```powershell
PS> $env:TEST = $null
PS> $env:TEST.Length
0

PS> Get-ChildItem env:TEST
Get-ChildItem: Cannot find path 'TEST' because it does not exist.
```

### Creating the Foo environment variable using New-Item with Environment provider

```powershell
New-Item -Path Env:\Foo -Value 'Bar'

Name                           Value
----
Foo                            Bar
```

### Copying, setting, listing, and removing environment variables using Item cmdlets

```powershell
Copy-Item -Path Env:\Foo -Destination Env:\Foo2 -PassThru
Set-Item -Path Env:\Foo2 -Value 'BAR'
Get-Item -Path Env:\Foo*
Remove-Item -Path Env:\Foo* -Verbose

Name                           Value
----
Foo2                           Bar

Name                           Value
----
Foo2                           BAR
Foo                            Bar

VERBOSE: Performing the operation "Remove Item" on target "Item: Foo2".
VERBOSE: Performing the operation "Remove Item" on target "Item: Foo".
```

### Getting a full list of environment variables

```powershell
Get-ChildItem Env:
```

### Setting an environment variable to an empty string using Set-Item (PowerShell 7.5+)

```powershell
PS> Set-Item env:TEST 'Foo'
PS> Get-ChildItem env:TEST

Name                           Value
----
TEST                           Foo
```

### Setting an environment variable to $null using Set-Item removes it (PowerShell 7.5+)

```powershell
PS> Set-Item env:TEST ''
PS> Get-ChildItem env:TEST

Name                           Value
----
TEST

PS> Set-Item -Path env:TEST -Value $null
PS> Get-ChildItem env:TEST
Get-ChildItem: Cannot find path 'TEST' because it does not exist.
```

### Creating a new environment variable using [Environment]::SetEnvironmentVariable()

```powershell
[Environment]::SetEnvironmentVariable('Foo','Bar')
[Environment]::GetEnvironmentVariable('Foo')

Bar
```

### Setting an environment variable to an empty string using SetEnvironmentVariable() (PowerShell 7.5+)

```powershell
PS> [Environment]::SetEnvironmentVariable('Foo','Bar')
PS> Get-ChildItem env:Foo

Name                           Value
----
Foo                            Bar

PS> [Environment]::SetEnvironmentVariable('Foo','')
PS> Get-ChildItem env:Foo

Name                           Value
----
Foo
```

### Setting an environment variable to a value using SetEnvironmentVariable() (PowerShell 7.5+)

```powershell
PS> [Environment]::SetEnvironmentVariable('Foo','bar')
PS> Get-ChildItem env:Foo

Name                           Value
----
Foo                            bar
```

### Setting an environment variable to $null using SetEnvironmentVariable() (PowerShell 7.5+)

```powershell
PS> [Environment]::SetEnvironmentVariable('Foo',$null)
PS> Get-ChildItem env:Foo

Name                           Value
----
Foo
```

### Creating persistent environment variables in PowerShell profile

```powershell
$Env:CompanyUri = 'https://internal.contoso.com'
$Env:PATH += ';C:\Tools'
```

### Saving an environment variable to the machine scope (Windows)

```powershell
[Environment]::SetEnvironmentVariable('Foo', 'Bar', 'Machine')
```

### Deleting an environment variable from the machine scope (Windows)

```powershell
[Environment]::SetEnvironmentVariable('Foo', '', 'Machine')
```

### Disabling the module analysis cache by setting PSModuleAnalysisCachePath to 'NUL' (Windows)

```powershell
# `NUL` here is a special device on Windows that can't be written to,
# on non-Windows you would use `/dev/null`
$Env:PSModuleAnalysisCachePath = 'NUL'
```

### Tracing errors when module analysis cache is disabled

```powershell
Trace-Command -PSHost -Name Modules -Expression {
  Import-Module Microsoft.PowerShell.Management -Force
}
```
### Getting the effective execution policy

```powershell
Get-ExecutionPolicy
```

### Getting all execution policies and displaying them in precedence order

```powershell
Get-ExecutionPolicy -List
```

### Getting the execution policy for the CURRENTUSER scope

```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

### Changing execution policy to RemoteSigned

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

### Setting execution policy for a particular scope (CurrentUser)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Removing execution policy for LocalMachine scope

```powershell
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
```

### Removing execution policy for CurrentUser scope

```powershell
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser
```

### Setting an execution policy for a new PowerShell session

```powershell
pwsh.exe -ExecutionPolicy AllSigned
```
# PowerShell Examples: FileSystem Provider

### Navigate to a drive
```powershell
Set-Location C:
```

### Get all files and directories in current location
```powershell
Get-ChildItem
```

### Copy files and directories recursively
```powershell
Copy-Item -Path C:\temp\* -Destination C:\Windows\Temp -Recurse -File
```

### Copy a single file
```powershell
Copy-Item -Path C:\a\a.txt -Destination C:\a\bb\a.txt
```

### Copy directory contents recursively
```powershell
Copy-Item -Path C:\a\* -Destination C:\c -Recurse
```

### Move a file
```powershell
Move-Item -Path C:\a\c.txt -Destination C:\a\aa
```

### Move a directory (error when directory is current location)
```powershell
C:\temp> Move-Item -Path C:\temp\ -Destination C:\Windows\Temp

Move-Item : Cannot move item because the item at 'C:\temp\' is in use.
At line:1 char:1
+ Move-Item C:\temp\ C:\temp2\
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Move-Item], PSInvalidOperationException
    + FullyQualifiedErrorId : InvalidOperation,Microsoft.PowerShell.Commands.MoveItemCommand
```

### Get content of a file
```powershell
Get-Content -Path Test.txt
```

### Pipe file content to another cmdlet
```powershell
Get-Content -Path Test.txt | ConvertTo-Html
```

### Access file content using variable syntax
```powershell
${C:\Windows\System32\drivers\etc\hosts}
```

### Append content to a file
```powershell
Add-Content -Path test.txt -Value "test content"
```

### Replace file content
```powershell
Set-Content -Path test.txt -Value "test content"
```

### Read file with custom delimiter
```powershell
$e = Get-Content C:\test\employees.txt -Delimited "End Of Employee Record"
$e[0]
```

### View ACL for a file
```powershell
Get-Acl -Path test.txt | Format-List -Property *
```

### Create a directory
```powershell
New-Item -Path C:\ -Name logfiles -Type Directory
```

### Create an empty file
```powershell
New-Item -Path C:\logfiles -Name log2.txt -Type File
```

### Create a file with content
```powershell
New-Item -Path C:\logfiles -Name log2.txt -Type File -Value "test log"
```

### Rename a file
```powershell
Rename-Item -Path C:\a\a.txt -NewName b.txt
```

### Rename a directory
```powershell
Rename-Item -Path C:\a\cc -NewName dd
```

### Delete a file
```powershell
Remove-Item -Path test.txt
```

### Delete files using wildcards
```powershell
Remove-Item -Path *.xml
```

### Export service data and invoke associated program
```powershell
Get-Service | Export-Csv -Path services.csv
Invoke-Item -Path services.csv
```

### Get system files recursively
```powershell
Get-ChildItem -File -System -Recurse
```

### Get hidden files
```powershell
Get-ChildItem -Attributes !Directory,!Directory+Hidden
```

### Get compressed and encrypted files
```powershell
Get-ChildItem -Attributes Compressed,Encrypted
```

### Get help for provider cmdlets
```powershell
Get-Help Get-ChildItem

Get-Help Get-ChildItem -Path c:
```
# PowerShell Examples: For Loop

### Multiple assignment in Init statement (comma separated)
```powershell
# Comma separated assignment expressions enclosed in parentheses.
for (($i = 0), ($j = 0); $i -lt 10; $i++)
{
    "`$i:$i"
    "`$j:$j"
}
```

### Multiple assignment in Init statement (sub-expression)
```powershell
# Sub-expression using the semicolon to separate statements.
for ($($i = 0;$j = 0); $i -lt 10; $i++)
{
    "`$i:$i"
    "`$j:$j"
}
```

### Multiple assignment in Repeat statement (comma separated)
```powershell
# Comma separated assignment expressions.
for (($i = 0), ($j = 0); $i -lt 10; $i++, $j++)
{
    "`$i:$i"
    "`$j:$j"
}
```

### Multiple assignment in Repeat statement (parentheses)
```powershell
# Comma separated assignment expressions enclosed in parentheses.
for (($i = 0), ($j = 0); $i -lt 10; ($i++), ($j++))
{
    "`$i:$i"
    "`$j:$j"
}
```

### Multiple assignment in Repeat statement (sub-expression)
```powershell
# Sub-expression using the semicolon to separate statements.
for ($($i = 0;$j = 0); $i -lt 10; $($i++;$j++))
{
    "`$i:$i"
    "`$j:$j"
}
```

### Multiple conditions using logical operators
```powershell
for (($i = 0), ($j = 0); $i -lt 10 -and $j -lt 10; $i++,$j++)
{
    "`$i:$i"
    "`$j:$j"
}
```

### Infinite loop (no conditions)
```powershell
$i = 1
for (;;)
{
    Write-Host $i
}
```

### Increment within statement list
```powershell
for (;;)
{
    $i++; Write-Host $i
}
```

### Increment in Repeat section
```powershell
$i=1
for (;;$i++)
{
    Write-Host $i
}
```

### Loop with condition
```powershell
$i=1
for(;$i -le 10;$i++)
{
    Write-Host $i
}
```

### Complete for loop with Init, Condition, and Repeat
```powershell
for($i=1; $i -le 10; $i++){Write-Host $i}
```

### For loop with carriage returns instead of semicolons
```powershell
for ($i = 0
  $i -lt 10
  $i++){
  $i
}
```

### Increment by 2 in each iteration
```powershell
for ($i = 0; $i -le 20; $i += 2)
{
    Write-Host $i
}
```

### One-line for loop
```powershell
for ($i = 0; $i -lt 10; $i++){Write-Host $i}
```

### Functional example: Rename files with zero-padded work item IDs
```powershell
$fileList = Get-ChildItem -Path ./work_items
$fileList | Sort-Object -Descending -Property Name

# Default the longest numeral count to 1, since it can't be smaller.
$longestNumeralCount = 1

# Regular expression to find the numerals in the filename - use a template
# to simplify updating the pattern as needed.
$patternTemplate = '-(?<WorkItemNumber>{{{0},{1}}})\.json'
$pattern         =  $patternTemplate -f $longestNumeralCount

# Iterate, checking the length of the work item number as a string.
for (
    $i = 0                 # Start at zero for first array item.
    $i -lt $fileList.Count # Stop on the last item in the array.
    $i++                   # Increment by one to step through the array.
) {
    if ($fileList[$i].Name -match $pattern) {
        $numeralCount = $Matches.WorkItemNumber.Length
        if ($numeralCount -gt $longestNumeralCount) {
            # Count is higher, check against it for remaining items.
            $longestNumeralCount = $numeralCount
            # Update the pattern to speed up the search, ignoring items
            # with a smaller numeral count using pattern matching.
            $pattern = $patternTemplate -f $longestNumeralCount
        }
    }
}
```

### Rename files with padded work item numbers
```powershell
# Regular expression to find the numerals in the filename, but only if the
# numeral count is smaller than the longest numeral count.
$pattern = $patternTemplate -f 1, ($longestNumeralCount - 1)
for (
    $i = 0                 # Start at zero for first array item.
    $i -lt $fileList.Count # Stop on the last item in the array.
    $i++                   # Increment by one to step through the array.
) {
    # Get the file from the array to process
    $file = $fileList[$i]

    # If the file doesn't need to be renamed, continue to the next file
    if ($file.Name -notmatch $pattern) {
        continue
    }

    # Get the work item number from the regular expression, create the
    # padded string from it, and define the new filename by replacing
    # the original number string with the padded number string.
    $workItemNumber = $Matches.WorkItemNumber
    $paddedNumber   = "{0:d$longestNumeralCount}" -f $workItemNumber
    $paddedName     = $file.Name -replace $workItemNumber, $paddedNumber

    # Rename the file with the padded work item number.
    $file | Rename-Item -NewName $paddedName
}
```

### Compare original and padded file lists
```powershell
$paddedList = Get-ChildItem -Path ./work_items

# Sort both file lists by name.
$sortedOriginal = $fileList    | Sort-Object -Property Name
$sortedPadded   = $renamedList | Sort-Object -Property Name

# Iterate over the arrays and output an object to simplify comparing how
# the arrays were sorted before and after padding the work item numbers.
for (
  $i = 0
  $i -lt $fileList.Count
  $i++
) {
    [pscustomobject] @{
        Index    = $i
        Original = $sortedOriginal[$i].Name
        Padded   = $sortedPadded[$i].Name
    }
}
```
# PowerShell Examples: Foreach Statement

### Basic foreach loop with array
```powershell
$letterArray = 'a','b','c','d'
foreach ($letter in $letterArray)
{
  Write-Host $letter
}
```

### Foreach with Get-ChildItem cmdlet
```powershell
foreach ($file in Get-ChildItem)
{
  Write-Host $file
}
```

### Foreach with if statement filter
```powershell
foreach ($file in Get-ChildItem)
{
  if ($file.Length -gt 100KB)
  {
    Write-Host $file
  }
}
```

### Display multiple properties in foreach loop
```powershell
foreach ($file in Get-ChildItem)
{
  if ($file.Length -gt 100KB)
  {
    Write-Host $file
    Write-Host $file.Length
    Write-Host $file.LastAccessTime
  }
}
```

### Count files with external variable
```powershell
$i = 0
foreach ($file in Get-ChildItem) {
  if ($file.Length -gt 100KB) {
    Write-Host $file 'file size:' ($file.Length / 1024).ToString('F0') KB
    $i = $i + 1
  }
}

if ($i -ne 0) {
  Write-Host
  Write-Host $i ' file(s) over 100KB in the current directory.'
}
else {
  Write-Host 'No files greater than 100KB in the current directory.'
}
```

### Format file length results
```powershell
($file.Length / 1024).ToString('F0')
```

### Advanced: Parse PowerShell scripts for function positions
```powershell
function Get-FunctionPosition {
  [CmdletBinding()]
  [OutputType('FunctionPosition')]
  param(
    [Parameter(Position = 0, Mandatory,
      ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('PSPath')]
    [System.String[]]
    $Path
  )

  process {
    try {
      $filesToProcess = if ($_ -is [System.IO.FileSystemInfo]) {
        $_
      } else {
        Get-Item -Path $Path
      }
      $parser = [System.Management.Automation.Language.Parser]
      foreach ($item in $filesToProcess) {
        if ($item.PSIsContainer -or
            $item.Extension -notin @('.ps1', '.psm1')) {
          continue
        }
        $tokens = $errors = $null
        $ast = $parser::ParseFile($item.FullName, ([ref]$tokens),
          ([ref]$errors))
        if ($errors) {
          $msg = "File '{0}' has {1} parser errors." -f $item.FullName,
            $errors.Count
          Write-Warning $msg
        }
        :tokenLoop foreach ($token in $tokens) {
          if ($token.Kind -ne 'Function') {
            continue
          }
          $position = $token.Extent.StartLineNumber
          do {
            if (-not $foreach.MoveNext()) {
              break tokenLoop
            }
            $token = $foreach.Current
          } until ($token.Kind -in @('Generic', 'Identifier'))
          $functionPosition = [pscustomobject]@{
            Name       = $token.Text
            LineNumber = $position
            Path       = $item.FullName
          }
          $addMemberSplat = @{
              InputObject = $functionPosition
              TypeName = 'FunctionPosition'
              PassThru = $true
          }
          Add-Member @addMemberSplat
        }
      }
    }
    catch {
      throw
    }
  }
}
```
# PowerShell Examples: Format.ps1xml Files

### Export format data for CultureInfo objects
```powershell
Get-FormatData -TypeName System.Globalization.CultureInfo |
  Export-FormatData -Path $HOME\Format\CultureInfo.Format.ps1xml
```

### Sample Format.ps1xml structure for CultureInfo
```powershell
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
  <ViewDefinitions>
    <View>
      <Name>System.Globalization.CultureInfo</Name>
      <ViewSelectedBy>
        <TypeName>System.Globalization.CultureInfo</TypeName>
      </ViewSelectedBy>
      <TableControl>
        <TableHeaders>
          <TableColumnHeader>
            <Width>16</Width>
          </TableColumnHeader>
          <TableColumnHeader>
            <Width>16</Width>
          </TableColumnHeader>
          <TableColumnHeader />
        </TableHeaders>
        <TableRowEntries>
          <TableRowEntry>
            <TableColumnItems>
              <TableColumnItem>
                <PropertyName>LCID</PropertyName>
              </TableColumnItem>
              <TableColumnItem>
                <PropertyName>Name</PropertyName>
              </TableColumnItem>
              <TableColumnItem>
                <PropertyName>DisplayName</PropertyName>
              </TableColumnItem>
            </TableColumnItems>
          </TableRowEntry>
        </TableRowEntries>
      </TableControl>
    </View>
  </ViewDefinitions>
</Configuration>
```

### Add new column headers to format file
```powershell
<TableHeaders>
  <TableColumnHeader>
    <Width>16</Width>
  </TableColumnHeader>
  <TableColumnHeader>
    <Width>16</Width>
  </TableColumnHeader>
  <TableColumnHeader>
    <Width>45</Width>
  </TableColumnHeader>
  <TableColumnHeader/>
</TableHeaders>
```

### Add new column item to table rows
```powershell
<TableRowEntries>
  <TableRowEntry>
    <TableColumnItems>
      <TableColumnItem>
        <PropertyName>LCID</PropertyName>
      </TableColumnItem>
      <TableColumnItem>
        <PropertyName>Name</PropertyName>
      </TableColumnItem>
      <TableColumnItem>
        <PropertyName>Calendar</PropertyName>
      </TableColumnItem>
      <TableColumnItem>
        <PropertyName>DisplayName</PropertyName>
      </TableColumnItem>
    </TableColumnItems>
  </TableRowEntry>
</TableRowEntries>
```

### Update format data with PrependPath
```powershell
Update-FormatData -PrependPath $HOME\Format\CultureInfo.Format.ps1xml
```

### Test the format change
```powershell
Get-Culture
```

### Export format data for DirectoryInfo custom view
```powershell
Get-FormatData -PowerShellVersion 5.1 -TypeName System.IO.DirectoryInfo |
   Export-FormatData -Path ./MyGciView.Format.ps1xml
Update-FormatData -AppendPath ./MyGciView.Format.ps1xml
```

### Complete custom view XML for Format-Table
```powershell
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
  <ViewDefinitions>
    <View>
      <Name>MyGciView</Name>
      <ViewSelectedBy>
        <TypeName>System.IO.DirectoryInfo</TypeName>
        <TypeName>System.IO.FileInfo</TypeName>
      </ViewSelectedBy>
      <GroupBy>
        <PropertyName>PSParentPath</PropertyName>
      </GroupBy>
      <TableControl>
        <TableHeaders>
          <TableColumnHeader>
            <Label>Mode</Label>
            <Width>7</Width>
            <Alignment>Left</Alignment>
          </TableColumnHeader>
          <TableColumnHeader>
            <Label>LastWriteTime</Label>
            <Width>26</Width>
            <Alignment>Right</Alignment>
          </TableColumnHeader>
          <TableColumnHeader>
            <Label>CreationTime</Label>
            <Width>26</Width>
            <Alignment>Right</Alignment>
          </TableColumnHeader>
          <TableColumnHeader>
            <Label>Length</Label>
            <Width>14</Width>
            <Alignment>Right</Alignment>
          </TableColumnHeader>
          <TableColumnHeader>
            <Label>Name</Label>
            <Alignment>Left</Alignment>
          </TableColumnHeader>
        </TableHeaders>
        <TableRowEntries>
          <TableRowEntry>
            <Wrap />
            <TableColumnItems>
              <TableColumnItem>
                <PropertyName>ModeWithoutHardLink</PropertyName>
              </TableColumnItem>
              <TableColumnItem>
                <PropertyName>LastWriteTime</PropertyName>
              </TableColumnItem>
              <TableColumnItem>
                <PropertyName>CreationTime</PropertyName>
              </TableColumnItem>
              <TableColumnItem>
                <PropertyName>Length</PropertyName>
              </TableColumnItem>
              <TableColumnItem>
                <PropertyName>Name</PropertyName>
              </TableColumnItem>
            </TableColumnItems>
          </TableRowEntry>
        </TableRowEntries>
      </TableControl>
    </View>
  </ViewDefinitions>
</Configuration>
```
# PowerShell Examples: Function Provider

### Navigate to Function drive
```powershell
Set-Location Function:
```

### Return to file system drive
```powershell
Set-Location C:
```

### Get all functions in current session
```powershell
Get-ChildItem -Path Function:
```

### Get function definition using Definition property
```powershell
(Get-Item -Path Function:more).Definition
```

### Get function definition using provider path
```powershell
$Function:more
```

### Get function definition with dash in name
```powershell
${Function:Clear-Host}
```

### Get specific function with formatting
```powershell
Get-Item -Path man | Format-Table -Wrap -AutoSize
```

### Get function from different locations
```powershell
PS C:\> Get-Item -Path Function:c:
PS Function:\> Get-Item -Path .\c:
```

### Create a new function
```powershell
New-Item -Path Function:Win32: -Value {Set-Location C:\Windows\System32}
```

### Create function with Global scope modifier
```powershell
function New-Function {
    param(
        [string] $Name,
        [scriptblock] $Script
    )

    $lp = "Function:\Global:$($Name)"
    Set-Item -LiteralPath $lp -Value $Script -PassThru -Force
}

New-Function -Name 'Win32:' -Script { Set-Location C:\Windows\System32 }
```

### Delete a function
```powershell
Remove-Item Function:more
```

### Change a function
```powershell
Set-Item -Path Function:prompt -Value {
  'PS '+ (Get-Date -Format t) + " " + (Get-Location) + '> '
  }
```

### Rename a function
```powershell
Rename-Item -Path Function:help -NewName gh
```

### Copy a function
```powershell
Copy-Item -Path Function:prompt -Destination Function:oldPrompt
```

### Get help for Function provider cmdlets
```powershell
Get-Help Get-ChildItem

Get-Help Get-ChildItem -Path Function:
```
# PowerShell Examples: Functions

### Simple function definition
```powershell
function Get-PowerShellProcess { Get-Process pwsh }
```

### Call a function
```powershell
Get-PowerShellProcess
```

### Filter function definition
```powershell
filter Get-EventMessage ([switch]$MessageOnly) {
  if ($MessageOnly) { Out-Host -InputObject $_.Message }
  else { $_ }
}
```

### Use filter function
```powershell
Get-WinEvent -LogName System -MaxEvents 100 | Get-EventMessage -MessageOnly
```

### Function with input processing blocks
```powershell
Function Test-ScriptCmdlet {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param ($Parameter1)
    begin{}
    process{}
    end{}
}
```

### Simple function to start PowerShell as admin
```powershell
function Start-PSAdmin { Start-Process PowerShell -Verb RunAs }
```

### Function to find new pictures
```powershell
function Get-NewPicture {
  $start = Get-Date -Month 1 -Day 1 -Year 2010
  $allPics = Get-ChildItem -Path $Env:USERPROFILE\*.jpg -Recurse
  $allPics | Where-Object {$_.LastWriteTime -gt $Start}
}
```

### Function with named parameters (param keyword)
```powershell
function <name> {
  param ([type]$Parameter1 [,[type]$Parameter2])
  <statement list>
}
```

### Function with parameters (alternative syntax)
```powershell
function Add-Numbers([int]$One, [int]$Two) {
    $One + $Two
}
```

### Function with parameter
```powershell
function Get-SmallFiles {
  param ($Size)
  Get-ChildItem $HOME | Where-Object {
    $_.Length -lt $Size -and !$_.PSIsContainer
  }
}
```

### Call function with named parameter
```powershell
Get-SmallFiles -Size 50
```

### Call function with positional parameter
```powershell
Get-SmallFiles 50
```

### Function with default parameter value
```powershell
function Get-SmallFiles ($Size = 100) {
  Get-ChildItem $HOME | Where-Object {
    $_.Length -lt $Size -and !$_.PSIsContainer
  }
}
```

### Function with PSDefaultValue attribute
```powershell
function Get-SmallFiles {
  param (
      [PSDefaultValue(Help = '100')]
      $Size = 100
  )
  Get-ChildItem $HOME | Where-Object {
    $_.Length -lt $Size -and !$_.PSIsContainer
  }
}
```

### Function with positional parameters using $args
```powershell
function Get-Extension {
  $name = $args[0] + ".txt"
  $name
}

Get-Extension myTextFile
```

### Function with switch parameter
```powershell
function Switch-Item {
  param ([switch]$On)
  if ($On) { "Switch on" }
  else { "Switch off" }
}
```

### Call function with switch parameter
```powershell
Switch-Item -On

Switch-Item

Switch-Item -On:$true

Switch-Item -On:$false
```

### Function using splatting
```powershell
function Get-MyCommand { Get-Command @args }
```

### Call function with splatted parameters
```powershell
Get-MyCommand -Name Get-ChildItem
```

### Function with process block for pipeline
```powershell
function Get-Pipeline
{
  process {"The value is: $_"}
}

1, 2, 4 | Get-Pipeline
```

### Function handling pipeline and parameter input
```powershell
function Get-SumOfNumbers {
    param (
        [int[]]$Numbers
    )

    begin { $retValue = 0 }

    process {
        if ($MyInvocation.ExpectingInput) {
           "Pipeline input: $_"
           $retValue += $_
        } else {
           foreach ($n in $Numbers) {
               "Command line input: $n"
               $retValue += $n
           }
        }
    }

    end { "Sum = $retValue" }
}

1,2,3,4 | Get-SumOfNumbers
Get-SumOfNumbers 1,2,3,4
```

### Function with begin and end blocks
```powershell
function Get-PipelineBeginEnd {
    begin   { "Begin: The input is $input" }
    end     { "End:   The input is $input" }
}

1, 2, 4 | Get-PipelineBeginEnd
```

### Function with process and end blocks
```powershell
function Get-PipelineInput
{
    process {"Processing:  $_ " }
    end     {"End:   The input is: $input" }
}

1, 2, 4 | Get-PipelineInput
```

### Function with global scope
```powershell
function Global:Get-DependentSvs {
  Get-Service | Where-Object {$_.DependentServices}
}
```

### List all functions
```powershell
Get-ChildItem Function:
```

### Display function definition
```powershell
(Get-ChildItem Function:help).Definition
```

### Display function definition (alternative syntax)
```powershell
$Function:help
```

### Get help for a function
```powershell
Get-Help Get-MyDisks
```
# PowerShell Examples: Group Policy Settings

### List PowerShell Core Policy files
```powershell
Get-ChildItem -Path $PSHOME -Filter *Core*Policy*
```

### Turn on module logging for a specific module
```powershell
Import-Module <Module-Name>
(Get-Module <Module-Name>).LogPipelineExecutionDetails = $true
```
# PowerShell Examples: Hash Tables

### Create a hashtable
```powershell
$hash = @{
    1       = 'one'
    2       = 'two'
    'three' = 3
}
$hash
```

### Create an ordered dictionary
```powershell
$dictionary = [ordered]@{
    1       = 'one'
    2       = 'two'
    'three' = 3
}
$dictionary
```

### Correct syntax for ordered hashtable
```powershell
$orderedHash = [ordered]@{}
```

### Cast ordered dictionary to hashtable
```powershell
[hashtable]$newHash = [ordered]@{
    Number = 1
    Shape = "Square"
    Color = "Blue"
}
$newHash
```

### Get hashtable properties
```powershell
$hash | Get-Member -MemberType Properties, ParameterizedProperty
```

### Get dictionary properties
```powershell
$dictionary | Get-Member -MemberType Properties, ParameterizedProperty
```

### Access hashtable keys
```powershell
PS> $hash.Keys
PS> $dictionary.Keys
```

### Access hashtable values
```powershell
PS> $hash.Values
PS> $dictionary.Values
```

### Access value using member notation
```powershell
PS> $hash.1
PS> $dictionary.2
```

### Access value using array index notation (hashtable)
```powershell
PS> $hash['three']
PS> $hash[2]
```

### Access value by indexing into values collection
```powershell
PS> ([array]$hash.Values)[2]
```

### Access dictionary value using index notation
```powershell
PS> $dictionary[1]
PS> ([array]$dictionary.Values)[1]
PS> $dictionary[[Object]1]
PS> $dictionary['three']
```

### Handle property name collisions
```powershell
$hashtable.psbase.Keys
```

### Iterate over keys using foreach
```powershell
$hash = [ordered]@{Number = 1; Shape = "Square"; Color = "Blue"}

foreach ($Key in $hash.Keys) {
    "The value of '$Key' is: $($hash[$Key])"
}
```

### Iterate over keys using ForEach-Object
```powershell
$hash.Keys | ForEach-Object {
    "The value of '$_' is: $($hash[$_])"
}
```

### Iterate using GetEnumerator with ForEach-Object
```powershell
$hash.GetEnumerator() | ForEach-Object {
    "The value of '$($_.Key)' is: $($_.Value)"
}
```

### Iterate using GetEnumerator and ForEach method
```powershell
$hash.GetEnumerator().ForEach({"The value of '$($_.Key)' is: $($_.Value)"})
```

### Create empty hashtable
```powershell
$hash = @{}
```

### Add key-value pair using array notation
```powershell
$hash["Time"] = "Now"
```

### Add key-value pair using Add method
```powershell
$hash.Add("Time", "Now")
```

### Add key-value pair using addition operator
```powershell
$hash = $hash + @{Time="Now"}
```

### Add values stored in variables
```powershell
$t = "Today"
$now = (Get-Date)

$hash.Add($t, $now)
```

### Remove key-value pair
```powershell
$hash.Remove("Time")
```

### Hashtable with process objects as values
```powershell
$p = @{
    "PowerShell" = (Get-Process powershell)
    "Notepad" = (Get-Process notepad)
}
```

### Display hashtable and access values
```powershell
PS> $p

PS> $p.PowerShell

PS> $p.Keys | ForEach-Object {$p.$_.Handles}
```

### Add service object as key
```powershell
$p = $p + @{
    (Get-Service WinRM) = ((Get-Service WinRM).Status)
}
```

### Display keys and access service properties
```powershell
PS> $p.Keys
PS> $p.Keys | ForEach-Object {$_.Name}
```

### Add nested hashtable
```powershell
$p = $p + @{
    "Hash2"= @{a=1; b=2; c=3}
}
```

### Access nested hashtable values
```powershell
PS> $p.Hash2

PS> $p.Hash2.b
```

### Sort hashtable keys alphabetically
```powershell
PS> $p.GetEnumerator() | Sort-Object -Property Key
```

### Sort hashtable values in descending order
```powershell
PS> $p.GetEnumerator() | Sort-Object -Property Value -Descending
```

### Create here-string for ConvertFrom-StringData
```powershell
$string = @"
Msg1 = Type "Windows".
Msg2 = She said, "Hello, World."
Msg3 = Enter an alias (or "nickname").
"@
```

### Convert string data to hashtable
```powershell
ConvertFrom-StringData $string
```
# PowerShell Examples: Hidden Keyword

### Class with hidden property
```powershell
class Car
{
   # Properties
   [string] $Color
   [string] $ModelYear
   [int] $Distance

   # Method
   [int] Drive ([int]$Miles)
   {
      $this.Distance += $Miles
      $this.Rides++
      return $this.Distance
   }

   # Hidden property of the Drive method
    hidden [int] $Rides = 0
}
```

### Create instance of class with hidden member
```powershell
$TestCar = [Car]::new()
```

### Get members (hidden property not shown)
```powershell
PS C:\Windows\system32> $TestCar | Get-Member
```

### Get members with Force parameter (shows hidden members)
```powershell
PS C:\Windows\system32> $TestCar | Get-Member -Force
```
# PowerShell Examples: Command History

### Set maximum history count
```powershell
$MaximumHistoryCount = 100
```
# PowerShell Examples: If Statement

### Simple if statement
```powershell
if ($a -gt 2) {
    Write-Host "The value $a is greater than 2."
}
```

### If statement with else
```powershell
if ($a -gt 2) {
    Write-Host "The value $a is greater than 2."
}
else {
    Write-Host ("The value $a is less than or equal to 2," +
        " is not created or is not initialized.")
}
```

### If statement with elseif and else
```powershell
if ($a -gt 2) {
    Write-Host "The value $a is greater than 2."
}
elseif ($a -eq 2) {
    Write-Host "The value $a is equal to 2."
}
else {
    Write-Host ("The value $a is less than 2 or" +
        " was not created or initialized.")
}
```

### Ternary operator for path test
```powershell
$message = (Test-Path $path) ? "Path exists" : "Path not found"
```

### Ternary operator for service control
```powershell
$service = Get-Service BITS
$service.Status -eq 'Running' ? (Stop-Service $service) : (Start-Service $service)
```

### Invalid ternary operators (these will fail)
```powershell
Test-Path .vscode   ? Write-Host 'exists'   : Write-Host 'not found'
(Test-Path .vscode) ? Write-Host 'exists'   : Write-Host 'not found'
(Test-Path .vscode) ? (Write-Host 'exists') : Write-Host 'not found'
```

### Valid ternary operator with parentheses
```powershell
(Test-Path .vscode) ? (Write-Host 'exists') : (Write-Host 'not found')
```
# PowerShell Examples: Intrinsic Members

### Create hashtable and view intrinsic members
```powershell
$hash = @{
    Age  = 33
    Name = 'Bob'
}

$hash | Get-Member -Force -MemberType MemberSet, CodeProperty
```

### Enumerate properties using psobject
```powershell
$hash.psobject.Properties | Select-Object Name, MemberType, Value
```

### Convert hashtable to PSCustomObject
```powershell
$user = [pscustomobject]$hash
$user.psobject.Properties | Select-Object Name, MemberType, Value
```

### View intrinsic members of PSCustomObject
```powershell
$user | Get-Member -Force -MemberType MemberSet, CodeProperty
```

### View type hierarchy using pstypenames
```powershell
$file = Get-Item C:\temp\test.txt
$file.pstypenames
```

### String Length and Count properties
```powershell
PS> $str = 'string'
PS> $str.Length
PS> $str.Count
```

### Array indexing on scalar types
```powershell
PS> (2)[0]
PS> (2)[-1]
PS> (2)[1] -eq $null
PS> (2)[0,0] -eq $null
```

### Create object using new() method
```powershell
$expression = New-Object -TypeName regex -ArgumentList 'pattern'
$expression = [regex]::new('pattern')
```
### Get jobs including child jobs

```powershell
Get-Job -IncludeChildJob

Id Name   PSJobTypeName State      HasMoreData   Location    Command
-- ----   ------------- -----      -----------   --------    -------
1  Job1   RemoteJob     Failed     True          localhost   Get-Process
2  Job2                 Completed  True          Server01    Get-Process
3  Job3                 Failed     False         localhost   Get-Process
```

### Get jobs filtered by child job state

```powershell
Get-Job -ChildJobState Failed

Id Name   PSJobTypeName State      HasMoreData   Location    Command
-- ----   ------------- -----      -----------   --------    -------
1  Job1   RemoteJob     Failed     True          localhost   Get-Process
3  Job3                 Failed     False         localhost   Get-Process
```

### Get child jobs using ChildJobs property

```powershell
(Get-Job Job1).ChildJobs

Id Name   PSJobTypeName State      HasMoreData   Location    Command
-- ----   ------------- -----      -----------   --------    -------
2  Job2                 Completed  True          Server01    Get-Process
3  Job3                 Failed     False         localhost   Get-Process
```

### Get a specific child job

```powershell
Get-Job Job3

Id Name   PSJobTypeName State      HasMoreData   Location    Command
-- ----   ------------- -----      -----------   --------    -------
3  Job3                 Failed     False         localhost   Get-Process
```

### Start jobs on multiple computers with AsJob parameter

```powershell
$invokeCommandSplat = @{
    ComputerName = 'localhost', 'Server01', 'Server02'
    ScriptBlock = {Get-Date}
    AsJob = $true
}
$j = Invoke-Command @invokeCommandSplat
```

### Display job name and child jobs

```powershell
$j | Format-List Name, ChildJobs

Name      : Job3
ChildJobs : {Job4, Job5, Job6}
```

### Display parent job status

```powershell
$j

Id Name   PSJobTypeName State      HasMoreData   Location
-- ----   ------------- -----      -----------   --------
3  Job3   RemotingJob   Failed     False         localhost,Server...
```

### Get all jobs including child jobs to see individual status

```powershell
Get-Job -IncludeChildJobs

Id  Name   PSJobTypeName State      HasMoreData   Location    Command
--  ----   ------------- -----      -----------   --------    -------
3   Job3   RemotingJob   Failed     False         localhost,Server...
4   Job4                 Completed  True          localhost   Get-Date
5   Job5                 Failed     False         Server01    Get-Date
6   Job6                 Completed  True          Server02    Get-Date
```

### Receive results from a specific child job

```powershell
Receive-Job -Name Job6 -Keep |
    Format-Table ComputerName, DateTime -AutoSize

ComputerName DateTime
------------ --------
Server02     Thursday, March 13, 2008 4:16:03 PM
```

### Start a local background job

```powershell
PS> Start-Job -Name LocalData {Get-Process}

Id Name        PSJobTypeName   State   HasMoreData   Location   Command
-- ----        -------------   -----   -----------   --------   -------
2  LocalData   BackgroundJob   Running        True   localhost  Get-Process
```

### Start a remote background job

```powershell
$invokeCommandSplat = @{
    ComputerName = 'Server01'
    AsJob = $true
    JobName = 'RemoteData'
    ScriptBlock = {Get-Process}
}
Invoke-Command @invokeCommandSplat

Id  Name        PSJobTypeName  State   HasMoreData   Location   Command
--  ----        -------------  -----   -----------   --------   -------
2   RemoteData  RemoteJob      Running        True   Server01   Get-Process
```
### Start a background job with script block

```powershell
Start-Job -ScriptBlock {Get-Process}
```

### Save job object in a variable

```powershell
$job = Start-Job -ScriptBlock {Get-Process}
```

### Use background operator to start a job

```powershell
$job = Get-Process &
```

### Get all jobs in current session

```powershell
Get-Job
```

### Get a specific job by ID

```powershell
$job = Get-Job -Id 1
```

### Receive job results

```powershell
Receive-Job -Job $job

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)    Id ProcessName
-------  ------    -----      ----- -----   ------    -- -----------
    103       4    11328       9692    56           1176 audiodg
    804      14    12228      14108   100   101.74  1740 CcmExec
    668       7     2672       6168   104    32.26   488 csrss
```

### Save job results to a variable

```powershell
$results = Receive-Job -Job $job
```

### Receive partial job results (without -Keep)

```powershell
C:\PS> Receive-Job -Job $job

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
-------  ------    -----      ----- -----   ------     -- -----------
    103       4    11328       9692    56            1176 audiodg
    804      14    12228      14108   100   101.74   1740 CcmExec

C:\PS> Receive-Job -Job $job

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
-------  ------    -----      ----- -----   ------     -- -----------
     68       3     2632        664    29     0.36   1388 ccmsetup
    749      22    21468      19940   203   122.13   3644 communicator
    905       7     2980       2628    34   197.97    424 csrss
   1121      25    28408      32940   174   430.14   3048 explorer
```

### Receive job results with -Keep parameter

```powershell
C:\PS> Receive-Job -Job $job -Keep

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
-------  ------    -----      ----- -----   ------     -- -----------
    103       4    11328       9692    56            1176 audiodg
    804      14    12228      14108   100   101.74   1740 CcmExec

C:\PS> Receive-Job -Job $job -Keep

Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
-------  ------    -----      ----- -----   ------     -- -----------
    103       4    11328       9692    56            1176 audiodg
    804      14    12228      14108   100   101.74   1740 CcmExec
     68       3     2632        664    29     0.36   1388 ccmsetup
    749      22    21468      19940   203   122.13   3644 communicator
    905       7     2980       2628    34   197.97    424 csrss
   1121      25    28408      32940   174   430.14   3048 explorer
```

### Wait for a specific job

```powershell
Wait-Job -Id 10
```

### Wait for a job with timeout

```powershell
Wait-Job -Id 10 -Timeout 120
```

### Stop a background job

```powershell
$job = Start-Job -ScriptBlock {Get-EventLog -Log System}
$job | Stop-Job
```

### Remove a job

```powershell
Remove-Job -Job $job
```

### Investigate a failed job

```powershell
$job = Start-Job -ScriptBlock {New-Item -Path HKLM:\Software\MyCompany}
Get-Job $job

Id Name  PSJobTypeName State  HasMoreData  Location  Command
-- ----  ------------- -----  -----------  --------  -------
1  Job1  BackgroundJob Failed False        localhost New-Item -Path HKLM:...
```

### Check job failure reason

```powershell
$job.ChildJobs[0].JobStateInfo.Reason
```
### Basic unary join operator with comma precedence

```powershell
-join "a", "b", "c"
a
b
c
```

### Unary join with parentheses

```powershell
-join ("a", "b", "c")
abc
```

### Unary join with variable

```powershell
$z = "a", "b", "c"
-join $z
abc
```

### Join three strings without delimiter

```powershell
-join ("Windows", "PowerShell", "2.0")
WindowsPowerShell2.0
```

### Join strings with space delimiter

```powershell
"Windows", "PowerShell", "2.0" -join " "
Windows PowerShell 2.0
```

### Join with multi-character delimiter

```powershell
$a = "WIND", "S P", "ERSHELL"
$a -join "OW"
WINDOWS POWERSHELL
```

### Join here-string lines with split

```powershell
$a = @'
a
b
c
'@

(-split $a) -join " "
a b c
```
### begin keyword in function

```powershell
function <name> {
    dynamicparam {<statement list>}
    begin {<statement list>}
    process {<statement list>}
    end {<statement list>}
}
```

### break keyword in loop

```powershell
while (<condition>) {
   <statements>
   ...

   break
   ...

   <statements>
}
```

### catch keyword with try

```powershell
try {<statement list>}
catch [[<error type>]] {<statement list>}
```

### class keyword definition

```powershell
class <class-name> {
    [[hidden] [static] <property-definition> ...]
    [<class-name>([argument-list>]) {<constructor-statement-list>} ...]
    [[hidden] [static] <method-definition> ...]
}
```

### continue keyword in loop

```powershell
while (<condition>) {
   <statements>
   ...

   continue
   ...

   <statements>
}
```

### data keyword for data section

```powershell
data <variable> [-SupportedCommand <cmdlet-name>] {<permitted content>}
```

### do-while loop

```powershell
do {<statement list>} while (<condition>)
```

### do-until loop

```powershell
do {<statement list>} until (<condition>)
```

### dynamicparam keyword in function

```powershell
function <name> {
   dynamicparam {<statement list>}
   begin {<statement list>}
   process {<statement list>}
   end {<statement list>}
}
```

### else keyword with if

```powershell
if (<condition>) {<statement list>}
else {<statement list>}
```

### elseif keyword

```powershell
if (<condition>) {<statement list>}
elseif (<condition>) {<statement list>}
else {<statement list>}
```

### end keyword in function

```powershell
function <name> {
   dynamicparam {<statement list>}
   begin {<statement list>}
   process {<statement list>}
   end {<statement list>}
}
```

### enum keyword definition

```powershell
enum <enum-name> {
    <label> [= <int-value>]
    ...
}
```

### exit keyword basic usage

```powershell
exit
exit <exitcode>
```

### exit with exit code example

```powershell
C:\scripts\test>type test.ps1
1
2
3
exit 4

C:\scripts\test>pwsh -File ./test.ps1
1
2
3

C:\scripts\test>echo %ERRORLEVEL%
4
```

### filter keyword

```powershell
filter <name> {<statement list>}
```

### finally keyword with try-catch

```powershell
try {<statement list>}
catch [<error type>] {<statement list>}
finally {<statement list>}
```

### for loop

```powershell
for (<initialize>; <condition>; <iterate>) { <statement list> }
```

### foreach loop

```powershell
foreach (<item> in <collection>) { <statement list> }
```

### function keyword with parameters

```powershell
function [<scope:>]<name> {
   param ([type]<$PName1> [, [type]<$PName2>])
   dynamicparam {<statement list>}
   begin {<statement list>}
   process {<statement list>}
   end {<statement list>}
}
```

### function with parameters in signature

```powershell
function [<scope:>]<name> [([type]<$PName1>, [[type]<$PName2>])] {
   dynamicparam {<statement list>}
   begin {<statement list>}
   process {<statement list>}
   end {<statement list>}
}
```

### if keyword conditional

```powershell
if (<condition>) {<statement list>}
```

### hidden keyword for class members

```powershell
hidden [data type] $member_name
```

### in keyword with foreach

```powershell
foreach (<item> in <collection>){<statement list>}
```

### param keyword in function

```powershell
function [<scope:>]<name> {
   param ([type]<$PName1>[, [[type]<$PName2>]])
   <statement list>
}
```

### process keyword in function

```powershell
function <name> {
   dynamicparam {<statement list>}
   begin {<statement list>}
   process {<statement list>}
   end {<statement list>}
}
```

### return keyword

```powershell
return [<expression>]
```

### switch keyword syntax 1

```powershell
switch [-Regex|-Wildcard|-Exact][-CaseSensitive] ( <value> )
{
   <string>|<number>|<variable>|{ <expression> } {<statement list>}
   <string>|<number>|<variable>|{ <expression> } {<statement list>}
   ...

   default {<statement list>}
}
```

### switch keyword syntax 2 with file

```powershell
switch [-Regex|-Wildcard|-Exact][-CaseSensitive] -File <filename>
{
   <string>|<number>|<variable>|{ <expression> } {<statement list>}
   <string>|<number>|<variable>|{ <expression> } {<statement list>}
   ...

   default {<statement list>}
}
```

### throw keyword

```powershell
throw [<object>]
```

### trap keyword

```powershell
trap [[<error type>]] {<statement list>}
```

### try keyword with catch and finally

```powershell
try {<statement list>}
catch [[<error type>]] {<statement list>}
finally {<statement list>}
```

### until keyword with do

```powershell
do {<statement list>} until (<condition>)
```

### using namespace

```powershell
using namespace <.NET-namespace>
```

### using module

```powershell
using module <module-name>
```

### using assembly

```powershell
using assembly <.NET-assembly-path>
```

### while loop

```powershell
while (<condition>) {
   <statements>
 }
```

### while with do loop

```powershell
do {<statement list>} while (<condition>)
```
### Finding the language mode of a session

```powershell
$ExecutionContext.SessionState.LanguageMode

ConstrainedLanguage
```

### Finding language mode of a session configuration

```powershell
(Get-PSSessionConfiguration -Name Test).LanguageMode

FullLanguage
```

### Setting the language mode

```powershell
$ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"
```
### Set current working location

```powershell
Set-Location C:\Program Files\PowerShell
```

### Change location to registry drive

```powershell
Set-Location HKLM:
```

### Access items using drive letter

```powershell
Get-ChildItem C:
```

### Access specific path

```powershell
Get-ChildItem C:\Windows
```

### Set location to Windows directory

```powershell
Set-Location C:\Windows
```

### Access items from other drives

```powershell
Get-ChildItem HKLM:\software
```

### Use period to represent current location

```powershell
Get-ChildItem .\System
```

### Use two periods for parent directory

```powershell
Get-ChildItem ..\"Program Files"
```

### Use backslash for drive root

```powershell
Get-ChildItem \Windows
```

### Access items in current location without path

```powershell
Get-ChildItem System
```
### Enable module logging for PSReadLine

```powershell
$psrl = Get-Module PSReadLine
$psrl.LogPipelineExecutionDetails = $true
Get-Module PSReadLine | Select-Object Name, LogPipelineExecutionDetails

Name       LogPipelineExecutionDetails
----       ---------------------------
PSReadLine                        True
```

### Example PowerShell logging configuration

```powershell
{
    "ModuleLogging": {
        "EnableModuleLogging": false,
        "ModuleNames": [
            "PSReadLine",
            "PowerShellGet"
        ]
    },
    "ScriptBlockLogging": {
        "EnableScriptBlockInvocationLogging": true,
        "EnableScriptBlockLogging": true
    },
    "LogLevel": "verbose"
}
```

### Query PowerShell logs in journald

```powershell
journalctl --grep powershell
```

### Query PowerShell syslog entries on Ubuntu

```powershell
cat /var/log/syslog | grep -i powershell
```

### Create PowerShell log configuration file

```powershell
sudo nano /etc/rsyslog.d/40-powershell.conf
```

### Verify rsyslog configuration file attributes

```powershell
ls -l /etc/rsyslog.d/40-powershell.conf

-rw-r--r-- 1 root root   67 Nov 28 12:51 40-powershell.conf
```

### Set file ownership to root

```powershell
sudo chown root:root /etc/rsyslog.d/40-powershell.conf
```

### Set file permissions

```powershell
sudo chmod 644 /etc/rsyslog.d/40-powershell.conf
```

### Restart rsyslog service

```powershell
sudo systemctl restart rsyslog.service
```

### Run PowerShell to generate log data

```powershell
pwsh
```

### Query PowerShell log file

```powershell
cat /var/log/powershell.log
```

### Stream PowerShell logs in realtime on macOS

```powershell
log stream --predicate "subsystem == 'com.microsoft.powershell'" --level info
```

### Export logs since specific date on macOS

```powershell
log show --start "2022-04-05 09:00:00" --predicate "subsystem == 'com.microsoft.powershell'"
```

### Export logs as JSON and convert to PowerShell objects

```powershell
log show --predicate "subsystem == 'com.microsoft.powershell'" --style json |
    ConvertFrom-Json | Set-Variable logRecord
```

### Enable info level logging on macOS

```powershell
sudo log config --subsystem com.microsoft.powershell --mode level:info,persist:info
```

### Reset log settings to defaults on macOS

```powershell
sudo log config --subsystem com.microsoft.powershell --reset
```
### Enable module logging for PSReadLine

```powershell
$psrl = Get-Module PSReadLine
$psrl.LogPipelineExecutionDetails = $true
Get-Module PSReadLine | Select-Object Name, LogPipelineExecutionDetails

Name       LogPipelineExecutionDetails
----       ---------------------------
PSReadLine                        True
```

### Register PowerShell event provider

```powershell
$PSHOME\RegisterManifest.ps1
```

### Unregister PowerShell event provider

```powershell
$PSHOME\RegisterManifest.ps1 -Unregister
```

### Enable script block logging via registry

```powershell
function Enable-PSScriptBlockLogging {
    $basePath = @(
        'HKLM:\Software\Policies\Microsoft'
        'PowerShellCore\ScriptBlockLogging'
    ) -join '\'

    if (-not (Test-Path $basePath)) {
        $null = New-Item $basePath -Force
    }

    Set-ItemProperty $basePath -Name EnableScriptBlockLogging -Value "1"
}
```

### Decrypt protected event logging messages

```powershell
Get-WinEvent Microsoft-Windows-PowerShell/Operational |
    Where-Object Id -EQ 4104 | Unprotect-CmsMessage
```
### Complex logical expression with -and and -or

```powershell
($a -gt $b) -and (($a -lt 20) -or ($b -lt 20))
```

### Logical AND operator

```powershell
(1 -eq 1) -and (1 -eq 2)   # Result is False
```

### Logical OR operator

```powershell
(1 -eq 1) -or (1 -eq 2)    # Result is True
```

### Logical EXCLUSIVE OR operator

```powershell
(1 -eq 1) -xor (2 -eq 2)   # Result is False
```

### Logical NOT operator with -not

```powershell
-not (1 -eq 1)             # Result is False
```

### Logical NOT operator with !

```powershell
!(1 -eq 1)                 # Result is False
```
### Three ways to enumerate collection members

```powershell
PS> Get-Service -Name event* | ForEach-Object -Process { $_.DisplayName }
Windows Event Log
COM+ Event System
PS> (Get-Service -Name event*).ForEach({ $_.DisplayName })
Windows Event Log
COM+ Event System
PS> (Get-Service -Name event*).DisplayName
Windows Event Log
COM+ Event System
```

### Access members of a non-enumerable object

```powershell
PS> $MyString = 'abc'
PS> $MyString.Length
3
PS> $MyString.ToUpper()
ABC
```

### Access missing members on non-enumerable object

```powershell
PS> $MyString = 'abc'
PS> $null -eq $MyString.DoesNotExist
True
PS> $MyString.DoesNotExist()
InvalidOperation: Method invocation failed because [System.String] does not contain a method named 'DoesNotExist'.
```

### Access members that exist on collection but not its items

```powershell
PS> [System.Collections.Generic.List[string]]$Collection = @('a', 'b')
PS> $Collection.IsReadOnly
False
PS> $Collection.Add('c')
PS> $Collection
a
b
c
```

### Access members that exist on collection and its items

```powershell
PS> [System.Collections.Generic.List[string]]$Collection = @('a', 'b', 'c')
PS> $Collection.Count
3
PS> $Collection | ForEach-Object -Process { $_.Count }
1
1
1
PS> $Collection.ToString()
System.Collections.Generic.List`1[System.String]
PS> $Collection | ForEach-Object -Process { $_.ToString() }
a
b
c
```

### Access hashtable property using psbase

```powershell
$hashtable.psbase.Keys
```

### Access members that exist on items but not collection

```powershell
PS> [System.Collections.Generic.List[string]]$Collection = @('a', 'b', 'c')
PS> $Collection.Length
1
1
1
PS> $Collection.ToUpper()
A
B
C
```

### Access members that don't exist

```powershell
PS> [System.Collections.Generic.List[string]]$Collection = @('a', 'b', 'c')
PS> $null -eq $Collection.DoesNotExist
True
PS> $Collection.DoesNotExist()
InvalidOperation: Method invocation failed because [System.String] does not
contain a method named 'DoesNotExist'.
```

### Access methods that exist only on some items

```powershell
PS> @('a', 1, 'c').ToUpper()
InvalidOperation: Method invocation failed because [System.Int32] does not
contain a method named 'ToUpper'.
```

### Access properties that exist only on some items

```powershell
PS> $CapitalizedProperty = @{
    MemberType = 'ScriptProperty'
    Name       = 'Capitalized'
    Value      = { $this.ToUpper() }
    PassThru   = $true
}
PS> [System.Collections.Generic.List[Object]]$MixedCollection = @(
    'a'
    ('b' | Add-Member @CapitalizedProperty)
    ('c' | Add-Member @CapitalizedProperty)
    'd'
)
PS> $MixedCollection.Capitalized
B
C
```

### Access members of nested collections

```powershell
# Get the count of items in the array.
PS> $a.Count
2
# Get the count of items in each nested item.
PS> $a.GetEnumerator().Count
2
1
# Call the ToUpper() method on all items in the nested array.
PS> $a = @(, ('bar', 'baz'), 'foo')
PS> $a.ToUpper()
BAR
BAZ
FOO
```

### Errors result in lost output - successful case

```powershell
class Class1 { [Object] Foo() { return 'Bar' } }
class Class2 { [void] Foo() { throw 'Error' } }
class Class3 {}

$example1 = ([Class1]::new(), [Class1]::new())
$example2 = ([Class1]::new(), [Class2]::new())
$example3 = ([Class1]::new(), [Class3]::new())
```

### Member-access enumeration success

```powershell
PS> $example1.Foo()
Bar
Bar
```

### Member-access enumeration with error

```powershell
PS> $example2.Foo()
Exception:
Line |
   2 |  class Class2 { [void] Foo() { throw 'Error' } }
     |                                ~~~~~~~~~~~~~
     | Error
```

### Member-access enumeration with missing method

```powershell
PS> $example3.Foo()
InvalidOperation: Method invocation failed because [Class3] does not contain
a method named 'Foo'.
```

### ForEach-Object enumeration comparison

```powershell
PS> $example2 | ForEach-Object -MemberName Foo
Bar
ForEach-Object: Exception calling "Foo" with "0" argument(s): "Error"
PS> $example3 | ForEach-Object -MemberName Foo
Bar
```

### PSCustomObject collections return null for missing properties

```powershell
PS> $foo = [pscustomobject]@{ Foo = 'Foo' }
PS> $bar = [pscustomobject]@{ Bar = 'Bar' }
PS> $baz = [pscustomobject]@{ Baz = 'Baz' }
PS> ConvertTo-Json ($foo, $bar, $baz).Foo
[
  "Foo",
  null,
  null
]
PS> ConvertTo-Json ((Get-Process -Id $PID), $foo).Name
[
  "pwsh",
  null
]
```
### Get methods of process objects

```powershell
Get-Process | Get-Member -MemberType Method

TypeName: System.Diagnostics.Process

Name                      MemberType Definition
----                      ---------- ----------
BeginErrorReadLine        Method     System.Void BeginErrorReadLine()
BeginOutputReadLine       Method     System.Void BeginOutputReadLine()
...
Kill                      Method     System.Void Kill()
Refresh                   Method     System.Void Refresh()
Start                     Method     bool Start()
ToString                  Method     string ToString()
WaitForExit               Method     bool WaitForExit(int milliseconds), ...
WaitForInputIdle          Method     bool WaitForInputIdle(int millisecon...
```

### Invoke Kill method on process

```powershell
$notepad = Get-Process notepad
$notepad.Kill()
```

### Invoke method inline with command

```powershell
(Get-Process Notepad).Kill()
```

### Use Replace method on string

```powershell
'this is rocket science'.Replace('rocket', 'rock')

this is rock science
```

### CopyTo method with destination only

```powershell
(Get-ChildItem C:\final.txt).CopyTo("C:\bin\final.txt")
```

### CopyTo method with overwrite parameter

```powershell
(Get-ChildItem C:\final.txt).CopyTo("C:\bin\final.txt", $true)
```

### Member-access enumeration example

```powershell
Notepad; Notepad; Notepad
$p = Get-Process Notepad
$p.Count

3
```

### Kill method on collection

```powershell
$p.Kill()
Get-Process Notepad
```

### ForEach-Object equivalent

```powershell
$p | ForEach-Object {$_.Kill()}
```

### Calling specific method overload with interface

```powershell
Add-Type -TypeDefinition @'

   // Interface
   public interface IFoo {
     string Bar(int p);
   }

   // Type that implements the interface
   public class Foo : IFoo {

   // Direct member method named 'Bar'
   public string Bar(object p) { return $"object: {p}"; }

   // *Explicit* implementation of IFoo's 'Bar' method().
   string IFoo.Bar(int p) {
       return $"int: {p}";
   }

}
'@
```

### Call less specific object overload

```powershell
[Foo]::new().Bar(1)

object: 1
```

### Cast to interface for specific overload

```powershell
([IFoo] [Foo]::new()).Bar(1)

int: 1
```
### Default minimal module manifest

```powershell
@{
# RootModule = ''
ModuleVersion = '1.0'
# CompatiblePSEditions = @()
GUID = 'e7184b71-2527-469f-a50e-166b612dfb3b'
Author = 'username'
CompanyName = 'Unknown'
Copyright = '(c) 2022 username. All rights reserved.'
# Description = ''
# PowerShellVersion = ''
# PowerShellHostName = ''
# PowerShellHostVersion = ''
# DotNetFrameworkVersion = ''
# CLRVersion = ''
# ProcessorArchitecture = ''
# RequiredModules = @()
# RequiredAssemblies = @()
# ScriptsToProcess = @()
# TypesToProcess = @()
# FormatsToProcess = @()
# NestedModules = @()
FunctionsToExport = @()
CmdletsToExport = @()
VariablesToExport = '*'
AliasesToExport = @()
# DscResourcesToExport = @()
# ModuleList = @()
# FileList = @()
PrivateData = @{
    PSData = @{
        # Tags = @()
        # LicenseUri = ''
        # ProjectUri = ''
        # IconUri = ''
        # ReleaseNotes = ''
        # ExternalModuleDependencies = @()
    } # End of PSData hashtable
} # End of PrivateData hashtable
# HelpInfoURI = ''
# DefaultCommandPrefix = ''
}
```

### RootModule as manifest type

```powershell
@{
    RootModule = ''
}
```

### ModuleVersion setting

```powershell
@{
    ModuleVersion = '1.2.3'
}
```

### Import module and inspect version

```powershell
$ExampleModule = Import-Module example.psd1
$ExampleModule.Version
$ExampleModule.Version.GetType().Name

Major  Minor  Build  Revision
-----  -----  -----  --------
1      2      3      -1

Version
```

### CompatiblePSEditions unspecified

```powershell
@{
    # CompatiblePSEditions = @()
}
```

### CompatiblePSEditions set to Core only

```powershell
@{
    CompatiblePSEditions = @('Core')
}
```

### Generate new GUID for module

```powershell
New-Guid | Select-Object -ExpandProperty Guid

8456b025-2fa5-4034-ae47-e6305f3917ca

@{
    GUID = '8456b025-2fa5-4034-ae47-e6305f3917ca'
}
```

### Import module by fully qualified name

```powershell
Import-Module -FullyQualifiedName @{
    ModuleName    = 'Example'
    GUID          = '8456b025-2fa5-4034-ae47-e6305f3917ca'
    ModuleVersion = '1.0.0'
}
```

### Author setting

```powershell
@{
    Author = 'Contoso Developer Experience Team'
}
```

### CompanyName setting

```powershell
@{
    CompanyName = 'Contoso, Ltd.'
}
```

### Copyright setting

```powershell
@{
    Copyright = '(c) 2022 Contoso, Ltd. All rights reserved.'
}
```

### Description setting

```powershell
@{
    Description = 'Example commands to show a valid module manifest'
}
```

### PowerShellVersion unspecified

```powershell
@{
    # PowerShellVersion = ''
}
```

### PowerShellVersion requiring 7.2 or higher

```powershell
@{
    PowerShellVersion = '7.2'
}
```

### Check PowerShell host name

```powershell
$Host.Name
Enter-PSSession -ComputerName localhost
$Host.Name

ConsoleHost
[localhost]: PS C:\Users\username\Documents> $Host.Name
ServerRemoteHost
```

### PowerShellHostName unspecified

```powershell
@{
    # PowerShellHostName = ''
}
```

### PowerShellHostName set to ServerRemoteHost

```powershell
@{
    PowerShellHostName = 'ServerRemoteHost'
}
```

### PowerShellHostVersion with host name

```powershell
@{
    PowerShellHostName = 'ConsoleHost'
    # PowerShellHostVersion = ''
}
```

### PowerShellHostVersion requiring 5.1

```powershell
@{
    PowerShellHostName    = 'ConsoleHost'
    PowerShellHostVersion = '5.1'
}
```

### DotNetFrameworkVersion unspecified

```powershell
@{
    # DotNetFrameworkVersion = ''
}
```

### DotNetFrameworkVersion requiring 4.0

```powershell
@{
    DotNetFrameworkVersion = '4.0'
}
```

### CLRVersion unspecified

```powershell
@{
    # CLRVersion = ''
}
```

### CLRVersion requiring 4.0

```powershell
@{
    CLRVersion = '4.0'
}
```

### ProcessorArchitecture unspecified

```powershell
@{
    # ProcessorArchitecture = ''
}
```

### ProcessorArchitecture set to Amd64

```powershell
@{
    ProcessorArchitecture = 'Amd64'
}
```

### RequiredModules unspecified

```powershell
@{
    # RequiredModules = @()
}
```

### RequiredModules with PSReadLine

```powershell
@{
    RequiredModules = @(
        'PSReadLine'
    )
}
```

### RequiredModules with vendored module path

```powershell
@{
    RequiredModules = @(
        'Vendored\PSReadLine\PSReadLine.psd1'
    )
}
```

### RequiredModules with specific version

```powershell
@{
    RequiredModules = @(
        @{
            ModuleName      = 'PSReadLine'
            RequiredVersion = '2.0.0'
        }
    )
}
```

### RequiredModules with minimum version

```powershell
@{
    RequiredModules = @(
        @{
            ModuleName    = 'PSReadLine'
            ModuleVersion = '2.0.0'
        }
    )
}
```

### RequiredModules with maximum version

```powershell
@{
    RequiredModules = @(
        @{
            ModuleName     = 'PSReadLine'
            MaximumVersion = '2.0.0'
        }
    )
}
```

### RequiredModules with version range

```powershell
@{
    RequiredModules = @(
        @{
            ModuleName     = 'PSDesiredStateConfiguration'
            ModuleVersion  = '2.0.0'
            MaximumVersion = '2.99.99'
        }
    )
}
```

### RequiredAssemblies setting

```powershell
@{
    RequiredAssemblies = @(
        'Assemblies\Example.dll'
    )
}
```

### ScriptsToProcess setting

```powershell
@{
    ScriptsToProcess = @(
        'Scripts\Initialize.ps1'
    )
}
```

### Example initialization script

```powershell
if ([string]::IsNullOrEmpty($ExampleState)) {
    Write-Information "Example not initialized."
    Write-Information "Initializing now..."
    $ExampleState = 'Initialized'
} else {
    Write-Information "Example already initialized."
}
```

### Import module with script execution

```powershell
$InformationPreference = 'Continue'
"Example State is: $ExampleState"
Import-Module .\example7x.psd1
"Example State is: $ExampleState"
Import-Module .\example7x.psd1 -Force

Example State is:

Example not initialized.
Initializing now...

Example State is: Initialized

Example already initialized.
```

### TypesToProcess setting

```powershell
@{
    TypesToProcess = @(
        'Types\Example.ps1xml'
    )
}
```

### FormatsToProcess setting

```powershell
@{
    FormatsToProcess = @(
        'Formats\Example.ps1xml'
    )
}
```

### NestedModules setting

```powershell
@{
    NestedModules = @(
        'Helpers\Helpers.psm1'
    )
}
```

### FunctionsToExport unspecified

```powershell
@{
    # FunctionsToExport = @()
}
```

### FunctionsToExport with wildcard

```powershell
@{
    FunctionsToExport = '*'
}
```

### FunctionsToExport as empty array

```powershell
@{
    FunctionsToExport = @()
}
```

### FunctionsToExport specific function

```powershell
@{
    FunctionsToExport = @(
        'Get-Example'
    )
}
```

### FunctionsToExport with wildcard pattern

```powershell
@{
    FunctionsToExport = @(
        '*Example'
    )
}
```

### CmdletsToExport unspecified

```powershell
@{
    # CmdletsToExport = @()
}
```

### CmdletsToExport with wildcard

```powershell
@{
    CmdletsToExport = '*'
}
```

### CmdletsToExport as empty array

```powershell
@{
    CmdletsToExport = @()
}
```

### CmdletsToExport specific cmdlet

```powershell
@{
    CmdletsToExport = @(
        'Get-Example'
    )
}
```

### CmdletsToExport with wildcard pattern

```powershell
@{
    CmdletsToExport = @(
        '*Example'
    )
}
```

### VariablesToExport unspecified

```powershell
@{
    # VariablesToExport = @()
}
```

### VariablesToExport with wildcard

```powershell
@{
    VariablesToExport = '*'
}
```

### VariablesToExport as empty array

```powershell
@{
    VariablesToExport = @()
}
```

### VariablesToExport specific variable

```powershell
@{
    VariablesToExport = @(
        'SomeExample'
    )
}
```

### VariablesToExport with wildcard pattern

```powershell
@{
    VariablesToExport = @(
        '*Example'
    )
}
```

### DscResourcesToExport unspecified

```powershell
@{
    # DscResourcesToExport = @()
}
```

### DscResourcesToExport specific resource

```powershell
@{
    DscResourcesToExport = @(
        'ExampleClassResource'
    )
}
```

### DscResourcesToExport multiple resources

```powershell
@{
    DscResourcesToExport = @(
        'ExampleClassResource'
        'ExampleMofResourceFirst'
    )
}
```

### ModuleList unspecified

```powershell
@{
    # ModuleList = @()
}
```

### ModuleList with modules

```powershell
@{
    ModuleList = @(
        'Example.psm1'
        'Submodules\First.psm1'
        'Submodules\Second.psm1'
    )
}
```

### FileList unspecified

```powershell
@{
    # FileList = @()
}
```

### FileList with files

```powershell
@{
    FileList = @(
        'Example.psd1'
        'Example.psm1'
        'Assemblies\Example.dll'
        'Scripts\Initialize.ps1'
        'Submodules\First.psm1'
        'Submodules\Second.psm1'
    )
}
```

### PrivateData with custom key

```powershell
@{
    PrivateData = @{
        PublishedDate = '2022-06-01'
    }
}
```

### Function accessing PrivateData

```powershell
function Get-Stale {
    [CmdletBinding()]
    param()

    $PublishedDate = $MyInvocation.MyCommand.Module.PrivateData.PublishedDate
    $CurrentDate = Get-Date

    try {
        $PublishedDate = Get-Date -Date $PublishedDate -ErrorAction Stop
    } catch {
        # The date was set in the manifest, set to an invalid value, or
        # the script module was directly imported without the manifest.
        throw "Unable to determine published date. Check the module manifest."
    }

    if ($CurrentDate -gt $PublishedDate.AddDays(30)) {
        Write-Warning "This module version was published more than 30 days ago."
    } else {
        $TimeUntilStale = $PublishedDate.AddDays(30) - $CurrentDate
        "This module will be stale in $($TimeUntilStale.Days) days"
    }
}
```

### Using Get-Stale function

```powershell
Get-Stale -TestDate '2022-06-15'
Get-Stale -TestDate '2022-08-01'

This module will be stale in 16 days

WARNING: This module version was published more than 30 days ago.
```

### HelpInfoUri setting

```powershell
@{
    HelpInfoUri = 'http://https://go.microsoft.com/fwlink/?LinkID=603'
}
```

### DefaultCommandPrefix setting

```powershell
@{
    DefaultCommandPrefix = 'Example'
}
```
### Multiplier Examples

```powershell
PS> 1kb
1024

PS> 1.30Dmb
1363148.80

PS> 0x10Gb
17179869184

PS> 1.4e23tb
1.5393162788864E+35

PS> 0x12Lpb
20266198323167232
```

### Numeric Type Conversion

```powershell
[int] '0xF' -eq 0xF
[int] '&hF' -eq 0xF
[int] '#F' -eq 0xF
[int] '0b1111' -eq 0b1111
[int] '0b1111' -eq 15
```

### Malformed Literal Error Example

```powershell
PS> 1usgb
At line:1 char:6
+ 1usgb
+      ~
The numeric constant 1usgb is not valid.
+ CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
+ FullyQualifiedErrorId : BadNumericConstant
```

### Accessing Properties and Methods - Failed Example

```powershell
PS> 2.GetType().Name
At line:1 char:11
+ 2.GetType().Name
+           ~
An expression was expected after '('.
+ CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
+ FullyQualifiedErrorId : ExpectedExpression
```

### Accessing Properties and Methods - Working Examples

```powershell
PS> 2uL.GetType().Name
UInt64
PS> 1.234.GetType().Name
Double
PS> (2).GetType().Name
Int32
```

### Parsing Large Value Literals - Precision Loss

```powershell
PS> [bigint]111111111111111111111111111111111111111111111111111111
111111111111111100905595216014112456735339620444667904
```

### Parsing Large Value Literals - String Conversion

```powershell
PS> [bigint]'111111111111111111111111111111111111111111111111111111'
111111111111111111111111111111111111111111111111111111
```

### Parsing Large Value Literals - Using N Suffix (PowerShell 7.0+)

```powershell
PS> 111111111111111111111111111111111111111111111111111111n
111111111111111111111111111111111111111111111111111111
```
### Viewing Type Constructors

```powershell
[System.Uri]::new

OverloadDefinitions
-------------------
uri new(string uriString)
uri new(string uriString, bool dontEscape)
uri new(uri baseUri, string relativeUri, bool dontEscape)
uri new(string uriString, System.UriKind uriKind)
uri new(uri baseUri, string relativeUri)
uri new(uri baseUri, uri relativeUri)
```

### Creating an Object Using Static new() Method

```powershell
[System.Uri]::new("https://www.bing.com")

AbsolutePath   : /
AbsoluteUri    : https://www.bing.com/
LocalPath      : /
Authority      : www.bing.com
...
```

### Listing Currently Loaded .NET Types

```powershell
[AppDomain]::CurrentDomain.GetAssemblies() |
  ForEach-Object {
    $_.GetExportedTypes() |
      ForEach-Object { $_.FullName }
  }
```

### Comparing DirectoryInfo Objects - PowerShell Provider

```powershell
$PSDirInfo = Get-Item /
$PSDirInfo | Get-Member | Group-Object MemberType | Select-Object Count, Name

Count Name
----- ----
    4 CodeProperty
   13 Property
    6 NoteProperty
    1 ScriptProperty
   18 Method
```

### Comparing DirectoryInfo Objects - Direct Construction

```powershell
$NewDirInfo = [System.IO.DirectoryInfo]::new('/')
$NewDirInfo | Get-Member | Group-Object MemberType | Select-Object Count, Name

Count Name
----- ----
    4 CodeProperty
   13 Property
    1 ScriptProperty
   18 Method
```

### Creating Custom Objects from Hash Tables

```powershell
function Test-Object {
  $ModuleName = "PSScheduledJob"
  $HelpCulture = "en-US"
  $HelpVersion = "3.1.0.0"
  [pscustomobject]@{
    "ModuleName"=$ModuleName
    "UICulture"=$HelpCulture
    "Version"=$HelpVersion
  }
  $ModuleName = "PSWorkflow"
  $HelpCulture = "en-US"
  $HelpVersion = "3.0.0.0"
  [pscustomobject]@{
    "ModuleName"=$ModuleName
    "UICulture"=$HelpCulture
    "Version"=$HelpVersion
  }
}
Test-Object

ModuleName        UICulture      Version
---------         ---------      -------
PSScheduledJob    en-US          3.1.0.0
PSWorkflow        en-US          3.0.0.0
```

### Accessing Custom Object Properties

```powershell
(Test-Object).ModuleName

 PSScheduledJob
 PSWorkflow
```

### Hash Table Order Preservation

```powershell
$hash = @{
    Name      = "Server30"
    System    = "Server Core"
    PSVersion = "4.0"
}
$Asset = [pscustomobject]$hash
$Asset

System      Name     PSVersion
------      ----     ---------
Server Core Server30 4.0
```

### Creating Session Option Object from Hash Table

```powershell
[System.Management.Automation.Remoting.PSSessionOption]@{
  IdleTimeout=43200000
  SkipCnCheck=$true
}
```

### Creating ProcessStartInfo Object from Hash Table

```powershell
[System.Diagnostics.ProcessStartInfo]@{
  CreateNoWindow="$true"
  Verb="run as"
}

Arguments               :
ArgumentList            : {}
CreateNoWindow          : True
EnvironmentVariables    : {OneDriveConsumer, PROCESSOR_ARCHITECTURE,
                           CommonProgramFiles(x86), APPDATA...}
Environment             : {[OneDriveConsumer, C:\Users\user1\OneDrive],
                           [PROCESSOR_ARCHITECTURE, AMD64],
                           [CommonProgramFiles(x86),
                           C:\Program Files (x86)\Common Files],
                           [APPDATA, C:\Users\user1\AppData\Roaming]...}
RedirectStandardInput   : False
RedirectStandardOutput  : False
RedirectStandardError   : False
...
```

### Using Hash Tables as Parameter Values

```powershell
New-PSSession -ComputerName Server01 -SessionOption @{
  IdleTimeout=43200000
  SkipCnCheck=$true
}
Register-ScheduledJob -Name Test -FilePath .\Get-Inventory.ps1 -Trigger @{
  Frequency="Daily"
  At="15:00"
}
```

### Creating Generic Dictionary Object

```powershell
$dict = New-Object 'System.Collections.Generic.Dictionary[String,Int]'
$dict.Add("One", 1)
$dict

Key Value
--- -----
One     1
```
### Objects in Pipelines

```powershell
Get-ChildItem C: | where { $_.PSIsContainer -eq $false } | Format-List
```
### Arithmetic Operators and Parentheses

```powershell
PS> 2 + 3 * 4
14

PS> (2 + 3) * 4
20
```

### Pipeline and Assignment Operator Precedence

```powershell
$read_only = Get-ChildItem *.txt | Where-Object {$_.IsReadOnly}
```

### Equivalent with Parentheses

```powershell
$read_only = ( Get-ChildItem *.txt | Where-Object {$_.IsReadOnly} )
```

### Index Operator Takes Precedence Over Cast

```powershell
PS> [string]@('Windows','PowerShell','2.0')[0]
Windows
```

### Cast Before Index Selection

```powershell
PS> ([string]@('Windows','PowerShell','2.0'))[0]
W
```

### Logical AND and Greater-Than Precedence

```powershell
PS> 2 -gt 4 -and 1
False
```

### Equivalent Expression with Parentheses

```powershell
PS> (2 -gt 4) -and 1
False
```

### Forcing Different Evaluation Order

```powershell
PS> 2 -gt (4 -and 1)
True
```
### Grouping Result Expressions

```powershell
PS> (Get-Item *.txt).Count -gt 10
True
```

### Grouping Assignment Statements

```powershell
PS> ($var = 1 + 2)
3
PS> ($var = 1 + 2) -eq 3
True
```

### Prefix and Postfix Increment Operators

```powershell
PS> $i = 0
PS> (++$i) # prefix
1
PS> $i = 0
PS> ($i++) # postfix
0
PS> $i
1
```

### Assignment in Conditional Statement

```powershell
if ($textFiles = Get-ChildItem *.txt) {
    $textFiles.Count
}
```

### Subexpression Operator

```powershell
PS> "Today is $(Get-Date)"
Today is 12/02/2019 13:15:20

PS> "Folder list: $((dir C:\ -Dir).Name -join ', ')"
Folder list: Program Files, Program Files (x86), Users, Windows
```

### Array Subexpression Operator

```powershell
PS> $list = @(Get-Process | Select-Object -First 10; Get-Service | Select-Object -First 10 )
PS> $list.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Object[]                                 System.Array

PS> $list.Count
20
PS> $list = @(Get-Service | Where-Object Status -EQ Starting )
PS> $list.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     Object[]                                 System.Array

PS> $list.Count
0
```

### Call Operator - Basic Usage

```powershell
PS> $c = "Get-ExecutionPolicy"
PS> $c
Get-ExecutionPolicy
PS> & $c
AllSigned
```

### Call Operator - Cannot Parse Command Parameters

```powershell
PS> $c = "Get-Service -Name Spooler"
PS> $c
Get-Service -Name Spooler
PS> & $c
& : The term 'Get-Service -Name Spooler' is not recognized as the name of a
cmdlet, function, script file, or operable program. Check the spelling of
the name, or if a path was included, verify that the path is correct and
try again.
```

### Call Operator vs Invoke-Expression

```powershell
PS> & "1+1"
&: The term '1+1' is not recognized as a name of a cmdlet, function, script
file, or executable program. Check the spelling of the name, or if a path was
included, verify that the path is correct and try again.

PS> Invoke-Expression "1+1"
2
```

### Call Operator - Script with Spaces in Path

```powershell
PS C:\Scripts> Get-ChildItem

    Directory: C:\Scripts


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        8/28/2018   1:36 PM             58 script name with spaces.ps1

PS C:\Scripts> ".\script name with spaces.ps1"
.\script name with spaces.ps1
PS C:\Scripts> & ".\script name with spaces.ps1"
Hello World!
```

### Background Operator - Basic Usage

```powershell
Get-Process -Name pwsh &
```

### Background Operator - Equivalent to Start-Job

```powershell
Start-Job -ScriptBlock {Get-Process -Name pwsh}
```

### Background Operator - With Receive-Job

```powershell
$job = Get-Process -Name pwsh &
Receive-Job $job -Wait


 NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
 ------    -----      -----     ------      --  -- -----------
      0     0.00     221.16      25.90    6988 988 pwsh
      0     0.00     140.12      29.87   14845 845 pwsh
      0     0.00      85.51       0.91   19639 988 pwsh

Remove-Job $job
```

### Background Operator - Statement Terminator

```powershell
$job = Get-Process -Name pwsh & Receive-Job $job -Wait


 NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
 ------    -----      -----     ------      --  -- -----------
      0     0.00     221.16      25.90    6988 988 pwsh
      0     0.00     140.12      29.87   14845 845 pwsh
      0     0.00      85.51       0.91   19639 988 pwsh
```

### Background Operator - Equivalent Script

```powershell
$job = Start-Job -ScriptBlock {Get-Process -Name pwsh}
Receive-Job $job -Wait
```

### Background Operator - Multiple Commands

```powershell
Get-Process -Name pwsh & Get-Service -Name BITS & Get-CimInstance -ClassName Win32_ComputerSystem &
```

### Cast Operator

```powershell
[datetime] '2/20/88' - [datetime] '1/20/88' -eq [timespan] '31'
```

### Comma Operator

```powershell
$myArray = 1,2,3
$SingleArray = ,1
Write-Output (,1)
```

### Dot Sourcing Operator

```powershell
. C:\scripts\sample.ps1 1 2 -Also:3
```

### Dot Sourcing - Current Directory

```powershell
. .\sample.ps1
```

### Format Operator - Basic Usage

```powershell
"{0} {1,-10} {2:N}" -f 1,"hello",[Math]::PI

1 hello      3.14
```

### Format Operator - Zero Padding

```powershell
"{0:00} {1:000} {2:000000}" -f 7, 24, 365

07 024 000365
```

### Format Operator - Escaping Curly Braces

```powershell
"{0} vs. {{0}}" -f 'foo'

foo vs. {0}
```

### Index Operator - Array Access

```powershell
PS> $a = 1, 2, 3
PS> $a[0]
1
PS> $a[-1]
3
PS> $a[2, 1, 0]
3
2
1

(Get-HotFix | Sort-Object InstalledOn)[-1]
```

### Index Operator - Hash Table Access

```powershell
$h = @{key="value"; name="PowerShell"; version="2.0"}
$h["name"]

PowerShell
```

### Index Operator - XML Access

```powershell
$x = [xml]"<doc><intro>Once upon a time...</intro></doc>"
$x["doc"]

intro
-----
Once upon a time...
```

### Index Operator - Non-Indexed Collection

```powershell
PS> (2)[0]
2
PS> (2)[-1]
2
PS> (2)[1] -eq $null
True
PS> (2)[0,0] -eq $null
True
```

### Pipeline Operator

```powershell
Get-Process | Get-Member
Get-Service | Where-Object {$_.StartType -eq 'Automatic'}
```

### Pipeline Chain Operators

```powershell
# If Get-Process successfully finds a process called notepad,
# Stop-Process -Name notepad is called
Get-Process notepad && Stop-Process -Name notepad

# If npm install fails, the node_modules directory is removed
npm install || Remove-Item -Recurse ./node_modules
```

### Range Operator - Number Ranges

```powershell
1..10
$max = 10
foreach ($a in 1..$max) {Write-Host $a}
```

### Range Operator - Reverse Order

```powershell
10..1
5..-5 | ForEach-Object {Write-Output $_}
```

### Range Operator - With Enumeration

```powershell
PS> enum Food {
      Apple
      Banana = 3
      Kiwi = 10
    }
PS> [Food]::Apple..[Food]::Kiwi
0
1
2
3
4
5
6
7
8
9
10
```

### Range Operator - Character Ranges

```powershell
PS> 'a'..'f'
a
b
c
d
e
f

PS> 'F'..'A'
F
E
D
C
B
A
```

### Range Operator - Character Range to String

```powershell
PS> [string]$s = 'a'..'e'
$s
a b c d e
$a = 'a', 'b', 'c', 'd', 'e'
$a
a b c d e
```

### Range Operator - Reverse ASCII Order

```powershell
PS> 'c'..'X'
c
b
a
`
_
^
]
\
[
Z
Y
X
```

### Member-Access Operator

```powershell
$myProcess.PeakWorkingSet
(Get-Process powershell).Kill()
'OS', 'Platform' | ForEach-Object { $PSVersionTable. $_ }
```

### Static Member Operator

```powershell
[datetime]::Now
'MinValue', 'MaxValue' | ForEach-Object { [int]:: $_ }
```

### Null-Coalescing Operator

```powershell
$x = $null
$x ?? 100

100
```

### Null-Coalescing Operator - Right-Hand Not Evaluated

```powershell
[string] $todaysDate = '1/10/2020'
$todaysDate ?? (Get-Date).ToShortDateString()

1/10/2020
```

### Null-Coalescing Assignment Operator

```powershell
$x = $null
$x ??= 100
$x

100
```

### Null-Coalescing Assignment Operator - Right-Hand Not Evaluated

```powershell
[string] $todaysDate = '1/10/2020'
$todaysDate ??= (Get-Date).ToShortDateString()
$todaysDate

1/10/2020
```

### Null-Conditional Member Access Operator

```powershell
$a = @{ PropName = 100 }
${a}?.PropName

100
```

### Null-Conditional Member Access - Returns Null

```powershell
$a = $null
${a}?.PropName
```

### Null-Conditional Element Access Operator

```powershell
$a = 1..10
${a}?[0]

1
```

### Null-Conditional Element Access - Returns Null

```powershell
$a = $null
${a}?[0]
```
### Finding Packages with Chocolatey Provider

```powershell
Find-Package -Provider Chocolatey <PackageName>
```

### Installing Package with Force Bootstrap

```powershell
Install-Package <Chocolatey package Name> -ForceBootstrap
```
### Basic Parsing Example

```powershell
Write-Host book
```

### Literal Expressions

```powershell
'hello'
32
```

### Variable Expressions

```powershell
$x
$Script:path
```

### Operator Expressions

```powershell
-12
-not $Quiet
3 + 7
$input.Length -gt 1
```

### Escaping Special Characters

```powershell
"The value of `$ErrorActionPreference is '$ErrorActionPreference'."

The value of $ErrorActionPreference is 'Continue'.
```

### Line Continuation with Backtick

```powershell
New-AzVm `
    -ResourceGroupName "myResourceGroupVM" `
    -Name "myVM" `
    -Location "EastUS" `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myNetworkSecurityGroup" `
    -PublicIpAddressName "myPublicIpAddress" `
    -Credential $cred
```

### Using Splatting Instead of Line Continuation

```powershell
$parameters = @{
    ResourceGroupName = "myResourceGroupVM"
    Name = "myVM"
    Location = "EastUS"
    VirtualNetworkName = "myVnet"
    SubnetName = "mySubnet"
    SecurityGroupName = "myNetworkSecurityGroup"
    PublicIpAddressName = "myPublicIpAddress"
    Credential = $cred
}
New-AzVm @parameters
```

### Native Command - PowerShell 2.0 with Escape Characters

```powershell
icacls X:\VMS /grant Dom\HVAdmin:`(CI`)`(OI`)F
```

### Stop-Parsing Token

```powershell
icacls X:\VMS --% /grant Dom\HVAdmin:(CI)(OI)F
```

### Stop-Parsing Token Example

```powershell
PS> cmd /c echo "a|b"
'b' is not recognized as an internal or external command,
operable program or batch file.
PS> cmd /c --% echo "a|b"
"a|b"
```

### Embedded Quotes Preserved (PowerShell 7.3+)

```powershell
PS> $a = 'a" "b'
PS> TestExe -echoargs $a 'c" "d' e" "f
Arg 0 is <a" "b>
Arg 1 is <c" "d>
Arg 2 is <e f>
```

### Empty Strings Preserved

```powershell
PS> TestExe -echoargs '' a b ''
Arg 0 is <>
Arg 1 is <a>
Arg 2 is <b>
Arg 3 is <>
```

### Passing Directory Path with Quotes - Windows/Standard Mode

```powershell
TestExe -echoargs """${Env:ProgramFiles(x86)}\Microsoft\"""
TestExe -echoargs '"C:\Program Files (x86)\Microsoft\"'
```

### Passing Directory Path with Quotes - Legacy Mode

```powershell
TestExe -echoargs """""${Env:ProgramFiles(x86)}\Microsoft\\"""""
TestExe -echoargs "\""C:\Program Files (x86)\Microsoft\\"""
TestExe -echoargs --% ""\""C:\Program Files (x86)\Microsoft\\"\"""
TestExe -echoargs --% """C:\Program Files (x86)\Microsoft\\""
TestExe -echoargs --% """%ProgramFiles(x86)%\Microsoft\\""
```

### End-of-Parameters Token

```powershell
Write-Output -- -InputObject

-InputObject
```

### End-of-Parameters Token with Expression

```powershell
Write-Output -- -InputObject $Env:PROCESSOR_ARCHITECTURE

-InputObject
AMD64
```

### End-of-Parameters Token with External Command

```powershell
TestExe -echoargs -a -b -- -c

Arg 0 is <-a>
Arg 1 is <-b>
Arg 2 is <-->
Arg 3 is <-c>
```

### Tilde Character - Home Directory Expansion

```powershell
PS D:\temp> $PWD

Path
----
D:\temp

PS D:\temp> Set-Location ~
PS C:\Users\user2> $PWD

Path
----
C:\Users\user2
```

### Tilde Character - Literal Character

```powershell
PS D:\temp> Set-Location ~
PS C:\Users\user2> New-Item -Type Directory -Name ~

    Directory: C:\Users\user2

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----            5/6/2024  2:08 PM                ~

PS C:\Users\user2> Set-Location ~
PS C:\Users\user2> Set-Location .\~
PS C:\Users\user2\~> $PWD

Path
----
C:\Users\user2\~
```

### Tilde Expansion for Native Commands (PowerShell 7.5-preview.2+)

```powershell
Trace-Command -Name ParameterBinding -Expression {
    findstr /C:\foo" ~\repocache.clixml
} -PSHost

DEBUG: 2024-05-06 15:13:46.8268 ParameterBinding Information: 0 : BIND NAMED native application line args [C:\Windows\system32\findstr.exe]
DEBUG: 2024-05-06 15:13:46.8270 ParameterBinding Information: 0 :     BIND cmd line arg [/C:\oo] to position [0]
DEBUG: 2024-05-06 15:13:46.8271 ParameterBinding Information: 0 :     BIND cmd line arg [C:\Users\user2\repocache.clixml] to position [1]
DEBUG: 2024-05-06 15:13:46.8322 ParameterBinding Information: 0 : CALLING BeginProcessing
```
### Basic Pipeline Example

```powershell
Command-1 | Command-2 | Command-3
```

### Get and Stop Process

```powershell
Get-Process notepad | Stop-Process
```

### Multi-Stage Pipeline with Filtering and Formatting

```powershell
Get-ChildItem -Path *.txt |
  Where-Object {$_.Length -gt 10000} |
    Sort-Object -Property Length |
      Format-Table -Property Name, Length

Name                       Length
----                       ------
tmp1.txt                    82920
tmp2.txt                   114000
tmp3.txt                   114000
```

### Starting a Service

```powershell
Get-Service wmi | Start-Service
```

### Adding Registry Entry

```powershell
Get-Item -Path HKLM:\Software\MyCompany |
  New-ItemProperty -Name NoOfEmployees -Value 8124
```

### Sorting Processes by Handles

```powershell
Get-Process | Sort-Object -Property Handles
```

### Displaying Process Properties

```powershell
Get-Process winlogon | Format-List -Property *
```

### Piping Native Command Output

```powershell
PS> ipconfig.exe | Select-String -Pattern 'IPv4'

   IPv4 Address. . . . . . . . . . . : 172.24.80.1
   IPv4 Address. . . . . . . . . . . : 192.168.1.45
   IPv4 Address. . . . . . . . . . . : 100.64.108.37
```

### Get-Help for Pipeline Parameters

```powershell
Get-Help Start-Service -Full
```

### Get-Help for Specific Parameter

```powershell
Get-Help Start-Service -Parameter *
```

### Pipeline vs InputObject Parameter

```powershell
Get-Service | Format-Table -Property Name, DependentServices
```

### Using InputObject with Variable

```powershell
$services = Get-Service
Format-Table -InputObject $services -Property Name, DependentServices
```

### Using InputObject with Embedded Command

```powershell
Format-Table -InputObject (Get-Service) -Property Name, DependentServices
```

### Array Enumeration in Pipeline

```powershell
@(1,2,3) | Measure-Object

Count    : 3
Average  :
Sum      :
Maximum  :
Minimum  :
Property :

@{"One"=1;"Two"=2} | Measure-Object

Count    : 1
Average  :
Sum      :
Maximum  :
Minimum  :
Property :
```

### Get-Member with Pipeline

```powershell
Get-Process | Get-Member

TypeName: System.Diagnostics.Process

Name      MemberType     Definition
----      ----------     ----------
Handles   AliasProperty  Handles = Handlecount
Name      AliasProperty  Name = ProcessName
NPM       AliasProperty  NPM = NonpagedSystemMemorySize
...
```

### Get-Member with InputObject

```powershell
Get-Member -InputObject (Get-Process)

TypeName: System.Object[]

Name               MemberType    Definition
----               ----------    ----------
Count              AliasProperty Count = Length
Address            Method        System.Object& Address(Int32 )
Clone              Method        System.Object Clone()
...
```

### Counting Processes

```powershell
(Get-Process).Count
```

### Downloading Binary File with Native Command (PowerShell 7.4+)

```powershell
$uri = 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/powershell-7.3.4-linux-arm64.tar.gz'

# native command redirected to a file
curl -s -L $uri > powershell.tar.gz
```

### Piping Byte-Stream to Native Command

```powershell
# native command output piped to a native command
curl -s -L $uri | tar -xzvf - -C .
```

### Piping PowerShell Byte-Stream to Native Command

```powershell
# byte stream piped to a native command
(Invoke-WebRequest $uri).Content | tar -xzvf - -C .

# bytes piped to a native command (all at once as byte[])
,(Invoke-WebRequest $uri).Content | tar -xzvf - -C .
```

### Pipeline Error Example

```powershell
Get-Item -Path HKLM:\Software\MyCompany\sales |
Move-ItemProperty -Path HKLM:\Software\MyCompany\design -Name product
```

### Tracing Parameter Binding

```powershell
Trace-Command -Name ParameterBinding -PSHost -FilePath debug.txt -Expression {
  Get-Item -Path HKLM:\Software\MyCompany\sales |
    Move-ItemProperty -Path HKLM:\Software\MyCompany\design -Name product
}
```

### Checking Parameter Properties

```powershell
Get-Help Move-ItemProperty -Parameter Destination

-Destination <String>
    Specifies the path to the destination location.

    Required?                    true
    Position?                    1
    Default value                None
    Accept pipeline input?       True (ByPropertyName)
    Accept wildcard characters?  false
```

### Checking Object Members

```powershell
Get-Item -Path HKLM:\Software\MyCompany\sales | Get-Member
```

### Fixed Command

```powershell
Get-Item -Path HKLM:\Software\MyCompany\design |
Move-ItemProperty -Destination HKLM:\Software\MyCompany\sales -Name product
```

### Multi-Line Pipeline - Traditional

```powershell
Command-1 |
    Command-2 |
    Command-3
```

### Multi-Line Pipeline - Pipe at Beginning (PowerShell 7+)

```powershell
# Wrapping with a pipe at the beginning of a line (no backtick required)
Get-Process | Where-Object CPU | Where-Object Path
    | Get-Item | Where-Object FullName -Match "AppData"
    | Sort-Object FullName -Unique

# Wrapping with a pipe on a line by itself
Get-Process | Where-Object CPU | Where-Object Path
    |
    Get-Item | Where-Object FullName -Match "AppData"
    |
    Sort-Object FullName -Unique
```
### Creating Object with New-Object and Add-Member

```powershell
PS> $object1 = New-Object -TypeName psobject
PS> Add-Member -InputObject $object1 -MemberType NoteProperty -Name one -Value 1
PS> Add-Member -InputObject $object1 -MemberType NoteProperty -Name two -Value 2
PS> $object1 | Get-Member

   TypeName: System.Management.Automation.PSCustomObject

Name        MemberType   Definition
----        ----------   ----------
Equals      Method       bool Equals(System.Object obj)
GetHashCode Method       int GetHashCode()
GetType     Method       type GetType()
ToString    Method       string ToString()
one         NoteProperty int one=1
two         NoteProperty int two=2

PS> $object1

one two
--- ---
  1   2
```

### Creating Object with New-Object Property Parameter

```powershell
PS> $object2 = New-Object -TypeName psobject -Property @{one=1; two=2}
PS> $object2 | Get-Member

   TypeName: System.Management.Automation.PSCustomObject

Name        MemberType   Definition
----        ----------   ----------
Equals      Method       bool Equals(System.Object obj)
GetHashCode Method       int GetHashCode()
GetType     Method       type GetType()
ToString    Method       string ToString()
one         NoteProperty int one=1
two         NoteProperty int two=2

PS> $object2

one two
--- ---
  1   2
```

### Creating Object with PSCustomObject Type Accelerator

```powershell
PS> $object3 = [pscustomobject]@{one=1; two=2}
PS> $object3 | Get-Member

   TypeName: System.Management.Automation.PSCustomObject

Name        MemberType   Definition
----        ----------   ----------
Equals      Method       bool Equals(System.Object obj)
GetHashCode Method       int GetHashCode()
GetType     Method       type GetType()
ToString    Method       string ToString()
one         NoteProperty int one=1
two         NoteProperty int two=2

PS> $object3

one two
--- ---
  1   2
```

### Order Preservation Example

```powershell
$hash = @{
    Name      = "Server30"
    System    = "Server Core"
    PSVersion = "4.0"
}
$Asset = [pscustomobject]$hash
$Asset

System      Name     PSVersion
------      ----     ---------
Server Core Server30 4.0
```

### Type Accelerator Comparison

```powershell
PS> [pscustomobject] -eq [System.Management.Automation.PSCustomObject]
False
```

### Type Accelerators Map to PSObject

```powershell
PS> [pscustomobject]

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     PSObject                                 System.Object

PS> [psobject]

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     PSObject                                 System.Object
```

### Type Checking with -is Operator

```powershell
PS> (Get-Item /) -is [pscustomobject]
True

PS> (Get-Item /) -is [psobject]
True
```

### Casting Different Types

```powershell
PS> ([psobject]@{Property = 'Value'}).GetType().FullName
System.Collections.Hashtable

PS> ([pscustomobject]123).GetType().Name
Int32

PS> ([pscustomobject]@{Property = 'Value'}).GetType().FullName
System.Management.Automation.PSCustomObject
```

### PSObject Wrapper Behavior

```powershell
PS> 1 -is [int32]
True
PS> 1 -is [psobject]
False
PS> ([psobject] 1) -is [int32]
True
PS> ([psobject] 1) -is [psobject]
True
```

### Format Operator with PSObject Wrapper

```powershell
PS> '{0} {1}' -f (1, 2)
1 2
PS> '{0} {1}' -f ([psobject] (1, 2))
Error formatting a string: Index (zero based) must be greater than or equal
to zero and less than the size of the argument list..
```

### Conversion of Hashtables with Similar Keys

```powershell
$Json = '{
  "One": 1,
  "two": 2,
  "Two": 3,
  "three": 3,
  "Three": 4,
  "THREE": 5
}'
$OrderedHashTable = $Json | ConvertFrom-Json -AsHashTable
$OrderedHashTable

Name                           Value
----                           -----
One                            1
two                            2
Two                            3
three                          3
Three                          4
THREE                          5
```

### Case Preservation in PSCustomObject

```powershell
[pscustomobject]$OrderedHashTable

One two three
--- --- -----
  1   3     5
```

### Count and Length Properties (Windows PowerShell)

```powershell
PS> $object = [pscustomobject]@{key = 'value'}
PS> $object

key
---
value

PS> $object.Count
PS> $object.Length
```
### Redirect errors and output to a file

```powershell
dir C:\, fakepath 2>&1 > .\dir.log
```

### Send all Success stream data to a file

```powershell
.\script.ps1 > script.log
```

### Send Success, Warning, and Error streams to a file

```powershell
&{
   Write-Warning "hello"
   Write-Error "hello"
   Write-Output "hi"
} 3>&1 2>&1 > C:\Temp\redirection.log
```

### Redirect all streams to a file

```powershell
.\script.ps1 *> script.log
```

### Suppress all Write-Host and Information stream data

```powershell
&{
   Write-Host "Hello"
   Write-Information "Hello" -InformationAction Continue
} 6> $null
```

### Show the effect of Action Preferences

```powershell
$ErrorActionPreference = 'Continue'
$ErrorActionPreference > log.txt
Get-Item /not-here 2>&1 >> log.txt

$ErrorActionPreference = 'SilentlyContinue'
$ErrorActionPreference >> log.txt
Get-Item /not-here 2>&1 >> log.txt

$ErrorActionPreference = 'Stop'
$ErrorActionPreference >> log.txt
try {
    Get-Item /not-here 2>&1 >> log.txt
}
catch {
    "`tError caught!" >> log.txt
}
$ErrorActionPreference = 'Ignore'
$ErrorActionPreference >> log.txt
Get-Item /not-here 2>&1 >> log.txt

$ErrorActionPreference = 'Inquire'
$ErrorActionPreference >> log.txt
Get-Item /not-here 2>&1 >> log.txt

$ErrorActionPreference = 'Continue'
```

### Redirecting binary data from curl

```powershell
$uri = 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.7/powershell-7.3.7-linux-arm64.tar.gz'

# native command redirected to a file
curl -s -L $uri > powershell.tar.gz
```

### Piping binary data between native commands

```powershell
# native command output piped to a native command
curl -s -L $uri | tar -xzvf - -C .
```

### Piping PowerShell byte-stream to native command

```powershell
# byte stream piped to a native command
(Invoke-WebRequest $uri).Content | tar -xzvf - -C .

# bytes piped to a native command (all at once as byte[])
,(Invoke-WebRequest $uri).Content | tar -xzvf - -C .
```

### Setting output width for file redirection

```powershell
$PSDefaultParameterValues['Out-File:Width'] = 2000
```

### Using AutoSize with wider output

```powershell
$PSDefaultParameterValues['Out-File:Width'] = 2000
Get-Service | Format-Table -AutoSize > services.log
```

### Potential confusion with comparison operators

```powershell
PS> if (36 > 42) { "true" } else { "false" }
false
```
### Passing variable by value (value type)

```powershell
Function Test($Data)
{
    $Data = 3
}

$var = 10
Test -Data $var
$var
```

### Passing hashtable by reference (reference type)

```powershell
Function Test($Data)
{
    $Data.Test = "New Text"
}

$var = @{}
Test -Data $var
$var
```

### Function accepting reference parameter

```powershell
function Test {
    param([ref]$Data)
    $Data.Value = 3
}

$var = 10
Test -Data ([ref]$var)
$var
```

### Using TryParse with reference parameter

```powershell
$number = 0
[int]::TryParse("15", ([ref]$number))
$number
```

### References and scopes

```powershell
# Create a value type variable.
$i = 0
# Create a reference type variable.
$iRef = [ref]0
# Invoke a scriptblock to attempt to change both values.
&{$i++;$iRef.Value++}
# Output the results.
"`$i = $i;`$iRef = $($iRef.Value)"
```

### Using [ref] as object holder for incremental renaming

```powershell
$iRef = [ref] 0
Get-ChildItem -File $setPath |
    Rename-Item -NewName { '{0} - {1}' -f $iRef.Value++,$_.Name }
```

### Difference between [ref] and [PSReference]

```powershell
$int = 1
$aRef = [ref] $int
$bRef = [System.Management.Automation.PSReference] $int
$int
$aRef, $bRef

$aRef.Value+=2
$bRef.Value+=5
$int
$aRef, $bRef
```
### Navigate to registry drive

```powershell
Set-Location HKLM:
```

### Return to file system drive

```powershell
Set-Location C:
```

### Navigate to registry key

```powershell
cd HKLM:\Software
```

### Using provider name syntax

```powershell
cd "Registry::HKEY_LOCAL_MACHINE\Software"
```

### Get registry key properties

```powershell
Get-Item -Path HKLM:\SYSTEM\CurrentControlSet\Services\Spooler
```

### Get subkeys of registry key

```powershell
Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Services\Spooler
```

### Get current location registry key

```powershell
cd HKLM:\System\CurrentControlSet\Services\Spooler
Get-Item .
```

### View all registry key properties

```powershell
$p = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Spooler
$p.DependOnService
```

### Get all properties from registry key

```powershell
Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Wbem
```

### Get specific property from registry key

```powershell
Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Wbem -Name BUILD
```

### Get property value only

```powershell
Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Microsoft\Wbem -Name BUILD
```

### Change registry key value

```powershell
Get-Service spooler | Select-Object Name, StartMode

$path = "HKLM:\SYSTEM\CurrentControlSet\Services\Spooler\"
Set-ItemProperty -Path $path -Name Start -Value 3
Get-Service spooler | Select-Object Name, StartMode

Set-Service -Name Spooler -StartupType Automatic
```

### Change default registry value

```powershell
Set-ItemProperty -Path HKLM:\SOFTWARE\Contoso -Name "(default)" -Value "one"
Set-Item -Path HKLM:\SOFTWARE\Contoso -Value "two"
```

### Create registry key

```powershell
mkdir ContosoCompany
```

### Create registry value

```powershell
$path = "HKLM:\SOFTWARE\ContosoCompany"
New-ItemProperty -Path $path -Name Test -Type DWord -Value 1
```

### Copy registry key

```powershell
Copy-Item -Path  HKLM:\Software\Contoso -Destination HKLM:\Software\Fabrikam
```

### Copy registry value

```powershell
$source = "HKLM:\SOFTWARE\Contoso"
$dest = "HKLM:\SOFTWARE\Fabrikam"
Copy-ItemProperty -Path $source -Destination $dest -Name Server
```

### Move registry key

```powershell
Move-Item -Path HKLM:\SOFTWARE\Contoso -Destination HKLM:\SOFTWARE\Fabrikam
```

### Move all registry properties

```powershell
$source = "HKLM:\SOFTWARE\Contoso"
$dest = "HKLM:\SOFTWARE\Fabrikam"
Move-ItemProperty -Path $source -Destination $dest -Name *
```

### Rename registry key and property

```powershell
$path = "HKLM:\SOFTWARE\Contoso"
Rename-ItemProperty -Path $path -Name ContosoTest -NewName FabrikamTest
Rename-Item -Path $path -NewName Fabrikam
```

### Change registry key security

```powershell
$acl = Get-Acl -Path HKLM:\SOFTWARE\Contoso
$rule = New-Object System.Security.AccessControl.RegistryAccessRule `
("CONTOSO\jsmith", "FullControl", "Allow")
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path HKLM:\SOFTWARE\Contoso
```

### Remove registry key with prompt

```powershell
Remove-Item -Path HKLM:\SOFTWARE\Contoso
```

### Remove registry key recursively

```powershell
Remove-Item -Path HKLM:\SOFTWARE\Contoso -Recurse
```

### Remove all items within registry key

```powershell
Remove-Item -Path HKLM:\SOFTWARE\Contoso\* -Recurse
```

### Remove registry value

```powershell
Remove-ItemProperty -Path HKLM:\SOFTWARE\Contoso -Name ContosoTest
```

### Clear all registry values

```powershell
Get-Item .\Contoso\

Clear-Item .\Contoso\
Get-Item .\Contoso\
```

### Get help for registry provider

```powershell
Get-Help Get-ChildItem

Get-Help Get-ChildItem -Path HKLM:
```
### Character literal match

```powershell
# This statement returns true because book contains the string "oo"
'book' -match 'oo'
```

### Character group match

```powershell
# This expression returns true if the pattern matches big, bog, or bug.
'big' -match 'b[iou]g'
```

### Character range match

```powershell
# This expression returns true if the pattern matches any 2 digit number.
42 -match '[0-9][0-9]'
```

### Decimal digit match

```powershell
# This expression returns true if it matches a server name.
# (Server-01 - Server-99).
'Server-01' -match 'Server-\d\d'
```

### Word character match

```powershell
# This expression returns true.
# The pattern matches the first word character 'B'.
'Book' -match '\w'
```

### Wildcard match

```powershell
# This expression returns true.
# The pattern matches any 4 characters except the newline.
'a1\ ' -match '....'
```

### Whitespace match

```powershell
# This expression returns true.
# The pattern uses the whitespace character class to match the leading
# space and a literal space to matching the trailing space.
' - ' -match '\s- '
```

### Zero or more quantifier

```powershell
# This returns true for all account name strings even if the name is absent.
'ACCOUNT NAME:    Administrator' -match 'ACCOUNT NAME:\s*\w*'
```

### One or more quantifier

```powershell
# This returns true if it matches any server name.
'DC-01' -match '[A-Z]+-\d\d'
```

### Zero or one quantifier

```powershell
# This returns true for any server name, even server names without dashes.
'SERVER01' -match '[A-Z]+-?\d\d'
```

### Specific count quantifier

```powershell
# This returns true if it matches any phone number.
'111-222-3333' -match '\d{3}-\d{3}-\d{4}'
```

### Anchor match

```powershell
# The pattern expects the string 'fish' to be the only thing on the line.
# This returns FALSE.
'fishing' -match '^fish$'
```

### Escaping special characters

```powershell
# This returns true and matches numbers with at least 2 digits of precision.
# The decimal point is escaped using the backslash.
'3.141' -match '3\.\d{2,}'
```

### Using regex escape method

```powershell
[regex]::Escape('3.\d{2,}')
```

### Capturing groups

```powershell
'The last logged on user was CONTOSO\jsmith' -match '(.+was )(.+)'

$Matches.0
```

### Accessing captures

```powershell
$Matches
```

### Accessing captures with different methods

```powershell
PS> 'Good Dog' -match 'Dog'
True

PS> $Matches[0]
Dog

PS> $Matches.Item(0)
Dog

PS> $Matches.0
Dog
```

### Named captures

```powershell
PS> $string = 'The last logged on user was CONTOSO\jsmith'
PS> $string -match 'was (?<domain>.+)\\(?<user>.+)'
True

PS> $Matches

PS> $Matches.domain
CONTOSO

PS> $Matches.user
jsmith
```

### Named captures from Windows event log

```powershell
$log = (Get-WinEvent -LogName Security -MaxEvents 1).Message
$r = '(?s).*Account Name:\s*(?<N>.*).*Account Domain:\s*(?<D>[A-Z,0-9]*)'
$log -match $r

$Matches
```

### Replace with numbered capture groups

```powershell
'John D. Smith' -replace '(\w+) (\w+)\. (\w+)', '$1.$2.$3@contoso.com'
```

### Replace with named capture groups

```powershell
'CONTOSO\Administrator' -replace '\w+\\(?<user>\w+)', 'FABRIKAM\${user}'
```

### Using $& for matched text

```powershell
'Gobble' -replace 'Gobble', '$& $&'
```

### String expansion with single and double quotes

```powershell
'Hello World' -replace '(\w+) \w+', '$1 Universe'
"Hello World" -replace "(\w+) \w+", "`$1 Universe"
```

### Literal dollar sign in replacement

```powershell
'5.72' -replace '(.+)', '$$$1'
"5.72" -replace "(.+)", "`$`$`$1"
```
### Start interactive session

```powershell
Enter-PSSession Server01
```

### End interactive session

```powershell
Exit-PSSession
```

### Run single remote command

```powershell
Invoke-Command -ComputerName Server01 -ScriptBlock {Get-Culture}
```

### Create persistent connection

```powershell
$s = New-PSSession -ComputerName Server01, Server02
```

### Run commands in PSSession

```powershell
Invoke-Command -Session $s -ScriptBlock {$p = Get-Process}
```

### Use persistent variable in PSSession

```powershell
Invoke-Command -Session $s -ScriptBlock {$p.Count}
```

### Run command on multiple computers

```powershell
Invoke-Command -ComputerName S1, S2, S3 -ScriptBlock {Get-Culture}
```

### Create multiple PSSessions

```powershell
$s = New-PSSession -ComputerName S1, S2, S3
Invoke-Command -Session $s -ScriptBlock {Get-Culture}
```

### Include local computer in remote command

```powershell
Invoke-Command -ComputerName S1, S2, S3, localhost -ScriptBlock {Get-Culture}
```

### Run local script on remote computers

```powershell
Invoke-Command -ComputerName S1, S2 -FilePath C:\Test\Sample.ps1
```
### Return syntax

```powershell
return
return $a
return (2 + $a)
```

### Return keyword to exit function early

```powershell
function MultiplyEven
{
    param($Number)

    if ($Number % 2) { return "$Number is not even" }
    $Number * 2
}

1..10 | ForEach-Object {MultiplyEven -Number $_}
```

### Returning value without return keyword

```powershell
$a
return
```

### Returning value with return keyword

```powershell
return $a
```

### Function with unintended output

```powershell
function Calculation {
    param ($Value)

    "Please wait. Working on calculation..."
    $Value += 73
    return $Value
}

$a = Calculation 14
```

### Using Write-Information to display message

```powershell
function Calculation {
    param ($Value)

    Write-Information "Please wait. Working on calculation..." -InformationAction Continue
    $Value += 73
    return $Value
}

$a = Calculation 14
```

### Returning array unrolls to pipeline

```powershell
function Test-Return
{
    $array = 1,2,3
    return $array
}
Test-Return | Measure-Object
```

### Unary array expression to return single object

```powershell
function Test-Return
{
    $array = 1,2,3
    return (, $array)
}
Test-Return | Measure-Object
```

### Write-Output with NoEnumerate parameter

```powershell
function Test-Return
{
    $array = 1, 2, 3
    return Write-Output -NoEnumerate $array
}

Test-Return | Measure-Object
```
### Get variables in local scope

```powershell
Get-Variable -Scope Local
```

### Get variables in global scope

```powershell
Get-Variable -Scope Global
```

### Create variable in local scope

```powershell
$a = "one"
```

### Create variable in global scope

```powershell
$Global:a = "one"
Get-Variable a | Format-List *
```

### Create private variable

```powershell
$Private:pVar = 'Private variable'
Get-Variable pVar | Format-List *
```

### Create variable in script scope

```powershell
$Script:a = "one"
```

### Create function in global scope

```powershell
function Global:Hello {
  Write-Host "Hello, World"
}
```

### Refer to variable in different scopes

```powershell
$test
$Global:test
```

### Using scope modifier with thread job

```powershell
$Count = 1
$refOfCount = Get-Variable Count

Start-ThreadJob {
    ($Using:refOfCount).Value = 2
} | Receive-Job -Wait -AutoRemoveJob

$Count
```

### Find cmdlets with Scope parameter

```powershell
Get-Help * -Parameter Scope
```

### Create variable in global scope

```powershell
New-Variable -Scope Global -Name a -Value "One"
```

### Create alias in global scope

```powershell
New-Alias -Scope Global -Name np -Value Notepad.exe
```

### Run script in script scope

```powershell
C:\scripts\sample.ps1
```

### Run script with call operator

```powershell
& C:\scripts\sample.ps1
```

### Run script in local scope using dot-sourcing

```powershell
. C:\scripts\sample.ps1
```

### Module scope example

```powershell
$a = "Hello"

function foo {
    "`$a = $a"
    "`$Global:a = $Global:a"
}
```

### Call module function

```powershell
$a = "Goodbye"
foo
```

### Example 1: Change variable value in script

```powershell
PS>  $ConfirmPreference
High

$ConfirmPreference = "Low"
"The value of `$ConfirmPreference is $ConfirmPreference."

PS>  $ConfirmPreference
High
```

### Example 2: View variable in different scopes

```powershell
$test = "Global"

# In Sample.ps1:
$test = "Local"
"The local value of `$test is $test."
"The global value of `$test is $Global:test."

PS> $test
Global
```

### Example 3: Change value in parent scope

```powershell
$test = "Global"

# In Sample.ps1:
$Global:test = "Local"
"The global value of `$test is $Global:test."

PS> $test
Local
```

### Example 4: Creating private variable

```powershell
# Start of ScopeExample.ps1
function funcA {
    "Setting `$funcAVar1 to 'Value set in funcA'"
    $funcAVar1 = "Value set in funcA"
    funcB
}

function funcB {
    "In funcB before set -> '$funcAVar1'"
    $Private:funcAVar1 = "Locally overwrite the value - child scopes can't see me!"
    "In funcB after set  -> '$funcAVar1'"
    funcC
}

function funcC {
    "In funcC before set -> '$funcAVar1' - should be the value set in funcA"
    $funcAVar1 = "Value set in funcC - Child scopes can see this change."
    "In funcC after set  -> '$funcAVar1'"
    funcD
}

function funcD {
    "In funcD before set -> '$funcAVar1' - should be the value from funcC."
    $funcAVar1 = "Value set in funcD"
    "In funcD after set  -> '$funcAVar1'"
    '-------------------'
    ShowScopes
}

function ShowScopes {
    $funcAVar1 = "Value set in ShowScopes"
    "Scope [0] (local)  `$funcAVar1 = '$(Get-Variable funcAVar1 -Scope 0 -ValueOnly)'"
    "Scope [1] (parent) `$funcAVar1 = '$(Get-Variable funcAVar1 -Scope 1 -ValueOnly)'"
    "Scope [2] (parent) `$funcAVar1 = '$(Get-Variable funcAVar1 -Scope 2 -ValueOnly)'"
    "Scope [3] (parent) `$funcAVar1 = '$(Get-Variable funcAVar1 -Scope 3 -ValueOnly)'"
    "Scope [4] (parent) `$funcAVar1 = '$(Get-Variable funcAVar1 -Scope 4 -ValueOnly)'"
}
funcA
# End of ScopeExample.ps1
```

### Example 5: Using local variable in remote command

```powershell
$Cred = Get-Credential
Invoke-Command $s {Remove-Item .\Test*.ps1 -Credential $Using:Cred}
```
### Traditional parameter syntax

```powershell
Copy-Item -Path "test.txt" -Destination "test2.txt" -WhatIf
```

### Hash table splatting

```powershell
$HashArguments = @{
  Path = "test.txt"
  Destination = "test2.txt"
  WhatIf = $true
}
Copy-Item @HashArguments
```

### Traditional positional parameters

```powershell
Copy-Item "test.txt" "test2.txt" -WhatIf
```

### Array splatting

```powershell
$ArrayArguments = "test.txt", "test2.txt"
Copy-Item @ArrayArguments -WhatIf
```

### ArgumentList parameter - first item only

```powershell
$array = 'Hello', 'World!'
Invoke-Command -ScriptBlock {
  param([string[]]$Words) $Words -join ' '
  } -ArgumentList $array
```

### ArgumentList parameter - wrapped array

```powershell
$array = 'Hello', 'World!'
Invoke-Command -ScriptBlock {
  param([string[]]$Words) $Words -join ' '
} -ArgumentList (,$array)
```

### Reuse splatted parameters

```powershell
$Colors = @{ForegroundColor = "black"; BackgroundColor = "white"}

#Write a message with the colors in $Colors
Write-Host "This is a test." @Colors

#Write second message with same colors. The position of splatted
#hash table does not matter.
Write-Host @Colors "This is another test."
```

### Forward parameters using $PSBoundParameters

```powershell
function Test1
{
    param($a, $b, $c)

    "a = $a"
    "b = $b"
    "c = $c"
}

function Test2
{
    param($a, $b, $c)

    #Call the Test1 function with $a, $b, and $c.
    Test1 @PSBoundParameters

    #Call the Test1 function with $b and $c, but not with $a
    Test1 -b $PSBoundParameters.b -c $PSBoundParameters.c
}

Test2 -a 1 -b 2 -c 3
```

### Override splatted parameters

```powershell
$commonParams = @{
    ResourceGroupName = "myResourceGroup"
    Location = "East US"
    VirtualNetworkName = "myVnet"
    SubnetName = "mySubnet"
    SecurityGroupName = "myNetworkSecurityGroup"
    PublicIpAddressName = "myPublicIpAddress"
}

$allVms = @('myVM1','myVM2','myVM3',)

foreach ($vm in $allVms)
{
    if ($vm -eq 'myVM2')
    {
        New-AzVm @commonParams -Name $vm -Location "West US"
    }
    else
    {
        New-AzVm @commonParams -Name $vm
    }
}
```

### Multiple splatted objects

```powershell
$a = @{
    Message         = 'Hello', 'World!'
}
$b = @{
    Separator       = '|'
}
$c = @{
    BackgroundColor = 'Cyan'
    ForegroundColor = 'Black'
}
Write-Host @a @b @c
```

### Splatting all parameters with @args

```powershell
function Get-MyProcess { Get-Process @args }

Get-MyProcess -Name powershell
```

### Using @args with explicitly declared parameters

```powershell
function Get-MyCommand
{
    param ([switch]$P, [switch]$C)
    if ($P) { Get-Process @args }
    if ($C) { Get-Command @args }
}

Get-MyCommand -P -C -Name powershell
```
### Unary split with default whitespace delimiter

```powershell
-split "red yellow blue green"
```

### Split by colon delimiter

```powershell
"Lastname:FirstName:Address" -split ":"
```

### Preserve delimiter in output

```powershell
"Lastname:FirstName:Address" -split "(:)"
```

### Split with complex delimiter pattern

```powershell
"Lastname/:/FirstName/:/Address" -split "/(:)/"
```

### Limit maximum substrings

```powershell
$c = "Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune"
$c -split ",", 5
```

### Split multiple strings with limit

```powershell
$c = 'a,b,c','1,2,3,4,5'
$c -split ',', 3
```

### Split with delimiter preservation and limit

```powershell
'Chocolate-Vanilla-Strawberry-Blueberry' -split '(-)', 3
```

### Negative value to split from end

```powershell
$c = "Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune"
$c -split ",", -5
```

### Split with script block

```powershell
$c = "Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune"
$c -split {$_ -eq "e" -or $_ -eq "p"}
```

### Unary split behavior with multiple strings

```powershell
PS> -split "1 2", "a b"
1
2
a b

PS> "1 2", "a b" -split " "
1
2
a
b

PS> -split ("1 2", "a b")
1
2
a
b

PS> $a = "1 2", "a b"
PS> -split $a
1
2
a
b
```

### Split at whitespace including newlines

```powershell
-split "Windows PowerShell 2.0`nWindows PowerShell with remoting"
```

### Split at comma

```powershell
"Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune" -split ','
```

### Split at pattern

```powershell
"Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune" -split 'er'
```

### Case-sensitive split

```powershell
"Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune" -csplit 'N'
```

### Split at multiple characters

```powershell
"Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune" -split '[et]'
```

### Split with character class and limit

```powershell
"Mercury,Venus,Earth,Mars,Jupiter,Saturn,Uranus,Neptune" -split '[er]', 6
```

### Split into three substrings

```powershell
"a,b,c,d,e,f,g,h" -split ",", 3
```

### Split from end with negative limit

```powershell
"a,b,c,d,e,f,g,h" -split ",", -3
```

### Split two strings independently

```powershell
"a,b,c,d", "e,f,g,h" -split ",", 3
```

### Split here-string with Multiline option

```powershell
$a = @'
1The first line.
2The second line.
3The third of three lines.
'@
$a -split "^\d", 0, "Multiline"
```

### Escape dot delimiter

```powershell
"This.is.a.test" -split "\."
```

### Split with SimpleMatch option

```powershell
"This.is.a.test" -split ".", 0, "SimpleMatch"
```

### Split with conditional delimiter

```powershell
$i = 1
$c = "LastName, FirstName; Address, City, State, Zip"
$c -split $(if ($i -lt 1) {","} else {";"})
```
### Simple switch statement

```powershell
switch (3) {
    1 { "It's one."   }
    2 { "It's two."   }
    3 { "It's three." }
    4 { "It's four."  }
}
```

### Multiple matching conditions

```powershell
switch (3) {
    1 { "It's one."    }
    2 { "It's two."    }
    3 { "It's three."  }
    4 { "It's four."   }
    3 { "Three again." }
}
```

### Using break and continue

```powershell
switch (1,4,-1,3,"Hello",2,1) {
    {$_ -lt 0}           { continue }
    {$_ -isnot [int32]}  { break }
    {$_ % 2}             { "$_ is Odd" }
    {-not ($_ % 2)}      { "$_ is Even" }
}
```

### Impact of string conversion

```powershell
switch ( ([datetime]'1 Jan 1970').DayOfWeek ) {
    4            { 'The integer value matches a Thursday.' }
    "4"          { 'The numeric string matches a Thursday.' }
    "Thursday"   { 'The string value matches a Thursday.' }
    { 4 -eq $_ } { 'The expression matches a Thursday.' }
}
```

### Hashtable string coercion

```powershell
$test = @{
    Test  = 'test'
    Test2 = 'test2'
}

$test.ToString()

switch -Exact ($test) {
    'System.Collections.Hashtable' { 'Hashtable string coercion' }
    'test'                         { 'Hashtable value' }
}
```

### Testing hashtable values

```powershell
$var = @{A = 10; B = 'abc'}

foreach ($key in $var.Keys) {
    switch ($var[$key].GetType()) {
        { $_ -eq [int32]  }  { "$key + 10 = $($var[$key] + 10)" }
        { $_ -eq [string] }  { "$key = $($var[$key])"           }
    }
}
```

### Switch with default clause

```powershell
switch ("fourteen") {
    1       { "It's one.";   break }
    2       { "It's two.";   break }
    3       { "It's three."; break }
    4       { "It's four.";  break }
    "fo*"   { "That's too many."   }
    default { "No matches"         }
}
```

### Switch with wildcard parameter

```powershell
switch -Wildcard ("fourteen") {
    1     { "It's one.";   break }
    2     { "It's two.";   break }
    3     { "It's three."; break }
    4     { "It's four.";  break }
    "fo*" { "That's too many."   }
}
```

### Switch with regex parameter

```powershell
$target = 'https://bing.com'
switch -Regex ($target) {
    '^ftp\://.*$'
        {
            "$_ is an ftp address"
            break
        }
    '^\w+@\w+\.com|edu|org$'
        {
            "$_ is an email address"
            break
        }
    '^(http[s]?)\://.*$'
        {
            "$_ is a web address that uses $($Matches[1])"
            break
        }
}
```

### Script block conditions

```powershell
switch ("Test") {
    { $_ -is [string] } { "Found a string" }
    "Test"              { "This $_ executes as well" }
}
```

### Processing array of dates

```powershell
switch ((Get-Date 1-Jan-2022), (Get-Date 25-Dec-2021)) {
    { $_.Year -eq 2021 }
        {
            $days = ((Get-Date 1/1/2022) - $_).Days
            "There are $days days until 2022."
        }
    { $_.Year -eq 2022 } { 'Welcome to 2022!' }
}
```

### Read file with switch

```powershell
switch -Regex -File .\README.md {
    '^##\s' { break }
    default { $_; continue }
}
```

### File parameter with wildcard

```powershell
switch -Regex -File .\README.* {
    '^##\s' { break }
    default { $_; continue }
}
```

### Escaping wildcard characters in filename

```powershell
$file = (New-Item -Path 'Temp:\Foo[0]' -Value Foo -Force).FullName
switch -File $file { Foo { 'Foo' } }

$fileEscaped = [WildcardPattern]::Escape($file)
switch -File $fileEscaped { foo { 'Foo' } }
```
# about_Updatable_Help

## Examples

### Example 1 - Getting help for a cmdlet without help files

```powershell
Get-Help Get-Culture

NAME
    Get-Culture

SYNTAX
    Get-Culture [<CommonParameters>]

ALIASES
    None

REMARKS
    To get the latest Help content including descriptions and examples
    type: Update-Help.
```

### Example 2 - Finding the module containing a cmdlet

```powershell
(Get-Command <cmdlet-name>).ModuleName

(Get-Command Set-ExecutionPolicy).ModuleName
```

### Example 3 - Updating help for a specific module

```powershell
Update-Help -Module <ModuleName>

Update-Help -Module Microsoft.PowerShell.Security
```

### Example 4 - Updating help for all modules

```powershell
Update-Help
```

### Example 5 - Updating help for wildcard module patterns

```powershell
Update-Help -Module ServerManager
```

### Example 6 - Saving help to a file share

```powershell
Save-Help -DestinationPath \\Server\Share
```

### Example 7 - Updating help from a file share

```powershell
Update-Help -SourcePath \\Server\Share
```

### Example 8 - Saving help for remote modules using Invoke-Command

```powershell
$invokeCommandSplat = @{
    ComputerName = 'RemoteServer'
    ScriptBlock = { Get-Module -Name DhcpServer -ListAvailable }
}
$m = Invoke-Command @invokeCommandSplat
Save-Help -Module $m -DestinationPath C:\SavedHelp
```

### Example 9 - Saving help for remote modules using PSSession

```powershell
$s = New-PSSession -ComputerName RemoteServer
$m = Get-Module -PSSession $s -Name DhcpServer -ListAvailable
Save-Help -Module $m -DestinationPath C:\SavedHelp
```

### Example 10 - Saving help for remote modules using CIM session

```powershell
$c = New-CimSession -ComputerName RemoteServer
$m = Get-Module -CimSession $c -Name DhcpServer -ListAvailable
Save-Help -Module $m -DestinationPath C:\SavedHelp
```

### Example 11 - Exporting module info to removable media

```powershell
$m = Get-Module -Name DhcpServer -ListAvailable
Export-Clixml -Path E:\UsbDrive\DhcpModule.xml -InputObject $m
```

### Example 12 - Importing module info and saving help

```powershell
$deserialized_m = Import-Clixml E:\UsbDrive\DhcpModule.xml
Save-Help -Module $deserialized_m -DestinationPath E:\UsbDrive\SavedHelp
```

### Example 13 - Installing help from removable media

```powershell
Update-Help -Module DhcpServer -SourcePath E:\UsbDrive\SavedHelp
```

### Example 14 - Saving help in multiple languages

```powershell
Save-Help -Path \Server\Share -UICulture ja-JP, fr-FR
```

### Example 15 - Opening online help for a cmdlet

```powershell
Get-Help Get-Job -Online
```
# about_Using

## Examples

### Example 1 - Getting cryptographic hash with namespace resolution

```powershell
using namespace System.Text
using namespace System.IO

[string]$string = "Hello World"
## VALID VALUES ARE "SHA1", "SHA256", "SHA384", "SHA512", "MD5"
[string]$algorithm = "SHA256"

[byte[]]$stringBytes = [UnicodeEncoding]::Unicode.GetBytes($string)

[Stream]$memoryStream = [MemoryStream]::new($stringBytes)
$getFileHashSplat = @{
    InputStream = $memoryStream
    Algorithm   = $algorithm
}
$hashFromStream = Get-FileHash @getFileHashSplat
$hashFromStream.Hash.ToString()
```

### Example 2 - Loading classes from a script module

```powershell
using module CardGames

[Deck]$deck = [Deck]::new()
$deck.Shuffle()
[Card[]]$hand1 = $deck.Deal(5)
[Card[]]$hand2 = $deck.Deal(5)
[Card[]]$hand3 = $deck.Deal(5)
```

### Example 3 - Loading types from an assembly and serializing to YAML

```powershell
using assembly './YamlDotNet.dll'
using namespace YamlDotNet

$yamlSerializer = [Serialization.Serializer]::new()

$info = [ordered]@{
  Inventory = @(
    @{ Name = 'Apples' ; Count = 1234 }
    @{ Name = 'Bagels' ; Count = 5678 }
  )
  CheckedAt = [datetime]'2023-01-01T01:01:01'
}

$yamlSerializer.Serialize($info)
```

### Example 4 - YAML output from serialization

```yaml
Inventory:
- Name: Apples
  Count: 1234
- Name: Bagels
  Count: 5678
CheckedAt: 2023-01-01T01:01:01.0000000
```
# about_Variable_Provider

## Examples

### Example 1 - Navigating to the Variable drive

```powershell
Set-Location Variable:
```

### Example 2 - Returning to a file system drive

```powershell
Set-Location C:
```

### Example 3 - Getting all variables in the current session

```powershell
Get-ChildItem -Path Variable:
```

### Example 4 - Getting a variable value using provider path

```powershell
$Variable:HOME
```

### Example 5 - Getting variables using wildcards

```powershell
Get-ChildItem -Path Variable:Max*
```

### Example 6 - Getting the value of the question mark variable

```powershell
Get-ChildItem -LiteralPath ?
```

### Example 7 - Getting ReadOnly and Constant variables

```powershell
Get-ChildItem -Path Variable: |
    Where-Object {
        $_.Options -match 'Constant' -or
        $_.Options -match 'ReadOnly'
    } |
    Format-List -Property Name, Value, Options
```

### Example 8 - Creating a new variable using relative path

```powershell
New-Item -Path . -Name services -Value (Get-Service)
```

### Example 9 - Creating a variable using an absolute path

```powershell
New-Item -Path Variable:services -Value Get-Service
```

### Example 10 - Renaming a variable

```powershell
Rename-Item -Path Variable:a -NewName processes
```

### Example 11 - Changing the value of a variable

```powershell
Set-Item -Path Variable:ErrorActionPreference -Value Stop
```

### Example 12 - Copying a variable

```powershell
Copy-Item -Path Variable:processes -Destination Variable:old_processes
```

### Example 13 - Deleting a variable

```powershell
Remove-Variable -Path Variable:serv
```

### Example 14 - Deleting variables using Force parameter

```powershell
Remove-Item Variable:* -Force
```

### Example 15 - Setting a variable value to null

```powershell
Clear-Item -Path Variable:processes
```

### Example 16 - Getting help for Variable provider cmdlets

```powershell
Get-Help Get-ChildItem

Get-Help Get-ChildItem -Path Variable:
```

### Example 17 - Creating a variable using expression parser

```powershell
$p = Get-Process
```
# about_Variables

## Examples

### Example 1 - Creating simple variables

```powershell
$MyVariable = 1, 2, 3

$Path = "C:\Windows\System32"
```

### Example 2 - Storing command results in variables

```powershell
$Processes = Get-Process

$Today = (Get-Date).DateTime
```

### Example 3 - Displaying variable values

```powershell
$MyVariable

1
2
3

$Today

Tuesday, September 3, 2019 09:46:46
```

### Example 4 - Changing variable values

```powershell
$MyVariable = 1, 2, 3
$MyVariable

1
2
3

$MyVariable = "The green cat."
$MyVariable

The green cat.
```

### Example 5 - Clearing and removing variables

```powershell
Clear-Variable -Name MyVariable

$MyVariable = $null

Remove-Variable -Name MyVariable

Remove-Item -Path Variable:\MyVariable
```

### Example 6 - Assigning the same value to multiple variables

```powershell
$a = $b = $c = 0
```

### Example 7 - Assigning multiple values to multiple variables

```powershell
$i,$j,$k = 10, "red", $true    # $i is 10, $j is "red", $k is True
$i,$j = 10, "red", $true       # $i is 10, $j is [Object[]], Length 2
```

### Example 8 - Variable data types

```powershell
$a = 12                         # System.Int32
$a = "Word"                     # System.String
$a = 12, "Word"                 # array of System.Int32, System.String
$a = Get-ChildItem C:\Windows   # FileInfo and DirectoryInfo types
```

### Example 9 - Using type attributes to restrict variable types

```powershell
[int]$number = 8
$number = "12345"  # The string is converted to an integer.
$number = "Hello"

Cannot convert value "Hello" to type "System.Int32". Error: "Input string
was not in a correct format."
```

### Example 10 - String type variable with type casting

```powershell
[string]$words = "Hello"
$words = 2       # The integer is converted to a string.
$words += 10     # The plus (+) sign concatenates the strings.
$words

210
```

### Example 11 - DateTime type variable with type casting

```powershell
[datetime] $dates = "09/12/91"  # The string is converted to a DateTime object.
$dates

Thursday, September 12, 1991 00:00:00

$dates = 10    # The integer is converted to a DateTime object.
$dates

Monday, January 1, 0001 00:00:00
```

### Example 12 - Using the PROFILE variable

```powershell
$PROFILE

C:\Users\User01\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

### Example 13 - Opening profile in Notepad

```powershell
notepad $PROFILE

notepad "$PROFILE"
```

### Example 14 - Single-quoted variable references

```powershell
'$PROFILE'

$PROFILE

'Use the $PROFILE variable.'

Use the $PROFILE variable.
```

### Example 15 - Creating variables with special characters in names

```powershell
${save-items} = "a", "b", "c"
${save-items}

a
b
c
```

### Example 16 - Accessing environment variables with special characters

```powershell
Get-ChildItem ${Env:ProgramFiles(x86)}
```

### Example 17 - Creating variables with braces in the name

```powershell
${this`{value`}is} = "This variable name uses braces and backticks."
${this`{value`}is}

This variable name uses braces and backticks.
```

### Example 18 - Creating a global scope variable

```powershell
$Global:Computers = "Server01"
```

### Example 19 - Adding variables to profile

```powershell
$VerbosePreference = "Continue"
```

### Example 20 - Navigating to the Variable drive

```powershell
Set-Location Variable:
```

### Example 21 - Listing variables in the Variable drive

```powershell
Get-ChildItem Variable:
```

### Example 22 - Getting a specific variable value

```powershell
Get-Item Variable:\PSCulture

Name                           Value
----                           -----
PSCulture                      en-US
```

### Example 23 - Getting help for Variable drive

```powershell
Get-Help Variable
```

### Example 24 - Listing variable-related cmdlets

```powershell
Get-Command -Noun Variable
```
# about_While

## Examples

### Example 1 - Basic while loop incrementing until condition is false

```powershell
while($val -ne 3)
{
    $val++
    Write-Host $val
}
```

### Example 2 - While loop written as a single command line

```powershell
while($val -ne 3){$val++; Write-Host $val}
```
# about_Wildcards

## Examples

### Example 1 - Finding all .ppt files in a directory

```powershell
Get-ChildItem C:\Techdocs\*.ppt
```

### Example 2 - Finding text files with names beginning with A through L

```powershell
Get-ChildItem C:\Techdocs\[a-l]*.txt
```

### Example 3 - Getting services with INTERACTIVE ServiceType

```powershell
Get-Service | Where-Object {$_.ServiceType -like "*Interactive*"}
```

### Example 4 - Filtering restore points by description

```powershell
$p = Get-ComputerRestorePoint
foreach ($point in $p) {
  if ($point.Description -like "*PowerShell*") {
    Add-Content -Path C:\TechDocs\RestoreLog.txt "$($point.CreationTime)"
  }
}
```

### Example 5 - Listing directory contents with bracketed filenames

```powershell
PS> Get-ChildItem

    Directory: D:\temp\test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           11/3/2025  3:39 PM             41 file[1].txt
-a---           11/3/2025  3:39 PM             41 file[2].txt
-a---           11/3/2025  3:39 PM             41 file[3].txt
```

### Example 6 - Getting a file with escaped backticks in the path

```powershell
PS> Get-Item -Path file``[1``].txt

    Directory: D:\temp\test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           11/3/2025  3:39 PM             41 file[1].txt
```

### Example 7 - Using single quotes to prevent backtick expansion

```powershell
PS> Get-Item -Path 'file`[1`].txt'

    Directory: D:\temp\test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           11/3/2025  3:39 PM             41 file[1].txt
```

### Example 8 - Using LiteralPath parameter to access file with literal bracket characters

```powershell
PS> Get-Item -LiteralPath file[1].txt

    Directory: D:\temp\test

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           11/3/2025  3:39 PM             41 file[1].txt
```
# about_Windows_PowerShell_Compatibility

## Examples

### Example 1 - Getting a PSSession in Windows PowerShell Compatibility mode

```powershell
$s = Get-PSSession -Name WinPSCompatSession
Invoke-Command -Session $s -ScriptBlock {
  "Running in Windows PowerShell version $($PSVersionTable.PSVersion)"
}
```

### Example 2 - Explicitly importing a module using UseWindowsPowerShell parameter

```powershell
Import-Module -Name ScheduledTasks -UseWindowsPowerShell
```

### Example 3 - Implicitly importing a Windows PowerShell module

```powershell
Import-Module -Name ServerManager
Get-AppLockerPolicy -Local
```

### Example 4 - Creating a configuration file that disables implicit module-loading

```powershell
$ConfigPath = "$PSHOME\DisableWinCompat.powershell.config.json"
$ConfigJSON = ConvertTo-Json -InputObject @{
  "DisableImplicitWinCompat" = $true
  "Microsoft.PowerShell:ExecutionPolicy" = "RemoteSigned"
}
$ConfigJSON | Out-File -Force $ConfigPath
pwsh -SettingsFile $ConfigPath
```

### Example 5 - Default WindowsPowerShellCompatibilityModuleDenyList setting

```powershell
"WindowsPowerShellCompatibilityModuleDenyList":  [
   "PSScheduledJob","BestPractices","UpdateServices"
]
```

### Example 6 - Default WindowsPowerShellCompatibilityNoClobberModuleList setting

```powershell
"WindowsPowerShellCompatibilityNoClobberModuleList": [ ]
```
