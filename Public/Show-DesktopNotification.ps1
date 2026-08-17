using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest

#### <h2 style="color: #DCA657;">Show-DesktopNotification</h2>
####
function Show-DesktopNotification {
    #### Raise a desktop toast through BurntToast.
    ####
    #### ```powershell
    #### Show-DesktopNotification -Title 'Search-PatternInFile complete' -Message "142 matches written to $jsonPath"
    #### ```
    ####
    #### <b style="color: #D2A8FF;">Parameters</b>
    ####
    [CmdletBinding()]
    param(
        #### - `[string]`: __Title__
        ####     - *Toast heading. Keep it to the command and its outcome.*
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        #### - `[string]`: __Message__
        ####     - *Toast body. Put the full output path here, since that is what the reader came back for.*
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        #### - `[string]`: __UniqueIdentifier__
        ####     - *Toasts sharing an identifier replace each other instead of stacking.*
        ####     - *Pass one when a command can run repeatedly, so the newest result is the one on screen.*
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UniqueIdentifier,

        #### - `[string]`: __LaunchPath__
        ####     - *File or folder the toast body opens when clicked.*
        ####     - *Without it the click activates the registered app, which is PowerShell.*
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LaunchPath
    )

    ####
    #### <b style="color: #C22514;">Throws</b>
    ####
    #### - When the host is not Windows.
    #### - When BurntToast is not installed.
    if (-not $IsWindows) {
        throw 'Show-DesktopNotification is Windows only.'
    }

    if (-not (Get-Module -ListAvailable -Name BurntToast)) {
        throw 'Show-DesktopNotification requires BurntToast. Install-Module BurntToast -Scope CurrentUser'
    }

    # New-BurntToastNotification cannot set what the toast body opens, so the
    # content is built directly. Nothing else about the toast changes.
    $children = (New-BTText -Text $Title), (New-BTText -Text $Message)
    $content = @{
        Visual = New-BTVisual -BindingGeneric (New-BTBinding -Children $children)
    }

    # Protocol activation hands the launch string to the shell. Without it the
    # click activates the app the toast is registered under, which is PowerShell.
    if (-not [string]::IsNullOrWhiteSpace($LaunchPath)) {
        $content['Launch'] = ([uri](Convert-Path -Path $LaunchPath)).AbsoluteUri
        $content['ActivationType'] = 'Protocol'
    }

    #### Splatted because UniqueIdentifier is optional, and passing it as an empty
    #### string would create a toast that every other empty-identifier toast replaces.
    $toast = @{
        Content = New-BTContent @content
    }
    if (-not [string]::IsNullOrWhiteSpace($UniqueIdentifier)) {
        $toast['UniqueIdentifier'] = $UniqueIdentifier
    }

    Submit-BTNotification @toast

    ####
    #### <b style="color: #369FFF;">Returns</b>
    ####
    #### - *Nothing.*
}
####
#### ---
####

