 <h2 style="color: #DCA657;">Search-PatternInFile</h2>

```powershell
function Search-PatternInFile
```
 Recursively searches files for a regex pattern.
 Writes every matching file and every occurrence inside it to a JSON file.

 The function writes `SearchPatternInFile.json` under `OutPath` and returns
 a summary containing the file count, the occurrence count, and the output path.

 Each entry in the file names one matching path and carries one record per
 matching line, the same shape `Select-String` reports: line number, the
 whole line, and every value matched on it.

 ## Examples

 ### Search for ToDo
 ```powershell
 Search-PatternInFile -Directory .\src -Pattern 'TODO' -OutPath .\results -Throttle 8
 ```

 ### Search for IP addresses

 ```powershell
 Search-PatternInFile -Directory C:\Users\DirWith\IP\Addresses\ `
 -Pattern '(?<IP>(?<![\d.])(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}(?![\d.]))' `
 -OutPath .\Generated\
 ```

 ### Search for home directory paths

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<HomePath>(?i)[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[^\\/\s"<>|,]+)' `
 -OutPath ..\Generated\
 ```

 ### Search for email addresses

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<Email>(?<![A-Za-z0-9._%+-])[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}(?![A-Za-z0-9.-]))' `
 -OutPath ..\Generated\
 ```

 ### Search for private key material

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<KeyHeader>-----BEGIN (?:[A-Z0-9 ]+ )?PRIVATE KEY-----)' `
 -OutPath ..\Generated\
 ```

 ### Search for AWS access key ids

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<AwsKey>(?<![A-Z0-9])(?:AKIA|ASIA)[0-9A-Z]{16}(?![A-Z0-9]))' `
 -OutPath ..\Generated\
 ```

 ### Search for JSON web tokens

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<Jwt>eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,})' `
 -OutPath ..\Generated\
 ```

 ### Search for hardcoded secret assignments

 ```powershell
 $keyword = 'password|passwd|pwd|secret|apikey|api_key|access_token'
 $value = '(?<Value>(?![$<{%(]|null\b|none\b)[^\s,;"]{6,})'
 Search-PatternInFile -Directory .\ `
 -Pattern "(?<Secret>(?i)\b(?:$keyword)\b\s*[=:]\s*$value)" `
 -OutPath ..\Generated\
 ```

 ### Search for download cradles and obfuscation

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<Cradle>(?i)\b(?:Invoke-Expression|IEX|DownloadString|DownloadFile|FromBase64String|EncodedCommand)\b)' `
 -OutPath ..\Generated\
 ```

 ### Search for social security numbers

 ```powershell
 Search-PatternInFile -Directory .\ `
 -Pattern '(?<Ssn>(?<!\d)\d{3}-\d{2}-\d{4}(?!\d))' `
 -OutPath ..\Generated\
 ```

 <b style="color: #D2A8FF;">Parameters</b>

 - `[string]`: __Directory__
     - *Directory to recursively enumerate files in.*
 - `[string]`: __Pattern__
     - *Regex passed to `Select-String -Pattern`.*
 - `[string]`: __OutPath__
     - *Directory where `SearchPatternInFile.json` is written.*
 - `[int]`: __Throttle__
     - *Maximum number of parallel workers. Defaults to 4.*

 <b style="color: #369FFF;">Returns</b>

 - `[string]`
     - *`<files> files, <matches> matches written to <path>`.*
     - *The matches themselves are in the file, not the return value.*

 <b style="color: #369FFF;">Side Effect</b>

 > Writes this PSCustomObject to a SearchPatternInFile.json in OutPath

 - `[PSCustomObject[]]`
     - *One entry per matching file, sorted by path.*
     - `[string]`: __Path__
         - *Full path of the matching file.*
     - `[int]`: __MatchCount__
         - *Occurrences found in that file, counting repeats on one line.*
     - `[PSCustomObject[]]`: __Matches__
         - *One entry per matching line, in file order.*
         - `[int]`: __LineNumber__ — *1-based line the match sits on.*
         - `[string]`: __Line__ — *The whole line, as `Select-String` reports it.*
         - `[string[]]`: __Values__ — *Every value matched on that line.*

 ---

