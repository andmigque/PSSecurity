 <h2 style="color: #DCA657;">Search-PatternInFile</h2>

```powershell
Describe 'Search-PatternInFile'
```

 <b style="color: #D2A8FF;">Cases</b>

 - The file holds exactly the matching paths. The matches live on disk, so
   this reads the file rather than the return value.
```powershell
It 'Records the matching files and excludes non-matching files'
```
 - Repeats on one line are counted, not collapsed. `many.txt` holds two on
   the first line and one on the third, so a line count and an occurrence
   count cannot be mistaken for each other.
```powershell
It 'Counts every occurrence and records one entry per matching line'
```
 - Each entry carries what `Select-String` reports: the line it sits on, the
   whole line, and the values matched on it.
```powershell
It 'Carries the line number, the line, and the matched values'
```
 - The result survives the session as a file under `OutPath`.
```powershell
It 'Writes SearchPatternInFile.json under OutPath'
```
 - The return value is a summary naming both counts and the file, not the
   matches. A long run can produce more matches than a terminal will hold.
```powershell
It 'Returns a summary naming both counts and the output file'
```
 - Emits exactly one object. Anything extra on the success stream would be
   the caller's problem to filter.
```powershell
It 'Emits a single summary line'
```
 - The notification is raised, carrying the same summary the caller receives.
   Asserting the mock ran is also what proves the real toast did not.
```powershell
It 'Raises a desktop notification carrying the summary'
```
 - Regression: without a launch path the toast activates the app it is
   registered under, which is PowerShell, so clicking the result opened a
   console instead of the findings.
```powershell
It 'Points the notification at the output file'
```
 - No match still writes an empty JSON array and reports zero.
```powershell
It 'Reports zero and writes an empty array when nothing matches'
```

 ---

