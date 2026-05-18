[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

#region useful functions
function Set-Editor {
    # Detect the operating system
    $os = [System.Environment]::OSVersion.Platform

    # Check if VS Code is installed by looking for the 'code' command
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $editor = "code"
    }
    elseif ($os -eq "Win32NT") {
        $editor = "notepad"
    }
    elseif ($os -eq "Unix") {
        if ($IsMacOS -or (uname) -match "Darwin") {
            $editor = "open -a TextEdit"  # Use TextEdit on macOS
        }
        else {
            # Prefer vim over nano if both are available
            if (Get-Command vim -ErrorAction SilentlyContinue) {
                $editor = "vim"
            }
            elseif (Get-Command nano -ErrorAction SilentlyContinue) {
                $editor = "nano"
            }
            else {
                $editor = "vi"  # Default to vi if neither vim nor nano is found
            }
        }
    }
    else {
        Write-Error "Operating system not supported."
        return $null
    }

    return $editor
}

$editor = Set-Editor

function Clear-HistoryFile {
    # Clear PSReadLine's in-memory history buffer
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()

    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path -Path $historyPath) {
        Remove-Item -Path $historyPath -Force -ErrorAction SilentlyContinue
    }
    Write-Output "History file was deleted!"
}

function Get-DNS {
    <#
    .SYNOPSIS
    Gets DNS controllers

    .DESCRIPTION
    Gets a list of DNS controllers in the domain

    .EXAMPLE
    Get-DNS
    #>
    $DNSServers = New-Object -TypeName System.Collections.Arraylist
    if ($null -eq $env:USERDNSDOMAIN) {
        Write-Output "Your computer is not joined to a domain!"
        break
    }
    $Results = ((& "$env:windir\system32\nltest.exe" /DnsGetDC:$env:USERDNSDOMAIN | Select-Object -Skip 2 | Select-Object -SkipLast 1).Trim() -Replace '\s+', ',')
    $Results | ForEach-Object {
        $null = $DNSServers.add((New-Object -TypeName PSObject -Property @{
                    Name = $_.Split(',')[0].Split('.')[0].toUpper()
                    IP   = $_.Split(',')[1]
                }))
    }
    $DNSServers | Sort-Object -Property IP
}

function ConvertTo-Base64String {
    [Alias('base', 'base64')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $InputObject,

        [Parameter()]
        [ArgumentCompleter([EncodingArgumentCompleter])]
        [EncodingArgumentConverter()]
        [Encoding] $Encoding
    )
    begin {
        if ($PSBoundParameters.ContainsKey((nameof { $Encoding }))) {
            $userEncoding = $Encoding
            return
        }

        $userEncoding = [Encoding]::Unicode
    }
    process {
        if ([string]::IsNullOrEmpty($InputObject)) {
            return
        }

        return [convert]::ToBase64String($userEncoding.GetBytes($InputObject))
    }
}

function Get-Tail {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({
                if (-not (Test-Path $_)) {
                    throw "File '$_' does not exist"
                }
                if (-not (Test-Path $_ -PathType Leaf)) {
                    throw "'$_' is not a file"
                }
                return $true
            })]
        [string]$FilePath
    )

    Get-Content -Path $FilePath -Wait
}

function New-Password {
    <#
    .SYNOPSIS
    Generates a password that meets the AD complexity requirements.

    .PARAMETER Size
    The length of password [Default: 15]

    .PARAMETER CharSets
    The character sets to be used [Default: ULNS]
    Valid options:
        [U]pper case
        [L]ower case
        [N]umerals
        [S]ymbols

    .PARAMETER Exclude
    Exclude specific characters that might e.g. lead to confusion like an alphanumeric O and a numeric 0 (zero).

    .EXAMPLE
    PS> New-Password -Size 12 -CharSets ULNS -Exclude "OLIoli01"

    This would generate a 12 characters long password that does not contain the characters OLIoli01

    .EXAMPLE
    PS> 1..10 | ForEach-Object { New-Password -Size 25 -CharSets ULNS }

    This would generate 10 password srtrings with a length of 25 chars
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = "Specify a length of password [Default: 15]")]
        [ValidateRange(1, [int]::MaxValue)]
        [Int]$Size = 15,

        [Parameter(Mandatory = $false, HelpMessage = "Specify the character sets to be used [Default: ULNS]")]
        [Char[]]$CharSets = "ULNS",

        [Parameter(Mandatory = $false, HelpMessage = "Specify the character sets to be excluded [Default: ULNS]")]
        [Char[]]$Exclude
    )

    process {
        $Chars = @()
        $output = @()
        If (!$TokenSets) {
            $script:TokenSets = @{
                U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'           # Upper case
                L = [Char[]]'abcdefghijklmnopqrstuvwxyz'           # Lower case
                N = [Char[]]'0123456789'                           # Numerals
                S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'    # Symbols
            }
        }
        $CharSets | ForEach-Object {
            $Tokens = $TokenSets."$_" | ForEach-Object { If ($Exclude -cNotContains $_) { $_ } }
            If ($Tokens) {
                $TokensSet += $Tokens
                If ($_ -cle [Char]"Z") { $Chars += $Tokens | Get-Random } # Character sets defined in upper case are mandatory
            }
        }
        While ($Chars.Count -lt $Size) { $Chars += $TokensSet | Get-Random }
        $output = ($Chars | Sort-Object { Get-Random }) -Join ""          # Mix the (mandatory) characters and output string

    }

    end {
        $output
    }
}

function Get-PrimaryMonitorSize {
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $res = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize | Select-Object Width, Height

    $Width = $res.Width - $res.Width * 10 / 100
    $Height = $res.Height - $res.Height * 10 / 100
    $Width, $Height
}

function Start-RDP {
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Enter the computer name or IP address to connect to")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern(
            '^(?=.{1,253}$)(([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)$|^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
            ErrorMessage = "'{0}' is not a valid hostname or IP address. Hostnames must contain only alphanumeric characters, hyphens, and dots, with a maximum of 253 characters total and each label up to 63 characters. IP addresses must be in valid IPv4 format."
        )]
        [ValidateScript(
            {
                try {
                    # Try to resolve the hostname
                    $resolveResult = [System.Net.Dns]::GetHostEntry($_)
                    if ($null -eq $resolveResult) {
                        throw "Unable to resolve hostname '$_'"
                    }
                    return $true
                }
                catch [System.Net.Sockets.SocketException] {
                    # If DNS resolution fails, check if it's reachable via Test-Connection
                    try {
                        $pingResult = Test-Connection -ComputerName $_ -Count 1 -Quiet -ErrorAction Stop
                        if ($pingResult) {
                            return $true
                        }
                        throw "Computer '$_' is not reachable on the network"
                    }
                    catch {
                        throw "Computer '$_' cannot be resolved or reached on the network. Verify the name is correct and the computer is online."
                    }
                }
                catch {
                    throw "Failed to validate computer name '$_': $($_.Exception.Message)"
                }
            },
            ErrorMessage = "Computer name validation failed: {0}"
        )]
        [string]$ComputerName,

        [switch]$NoFullScreen,
        [switch]$NoRemoteGuard
    )
    try {
        $mstsc = (Get-Command mstsc).Source
        $mstscParam = '/remoteGuard /prompt'

        if ($NoRemoteGuard.IsPresent) {
            $mstscParam = $mstscParam -replace ('/remoteGuard', '')
        }

        if ($NoFullScreen.IsPresent) {
            [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
            $res = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize | Select-Object Width, Height
            $Width = $res.Width
            $Height = $res.Height

            # switch to 16/9 aspect ratio
            $ratio = 16 / 9
            $displayRatio = $Width / $Height

            if ($displayRatio -gt $ratio) {
                $finalWidth = $Height * $ratio
                $finalHeight = $Height
            }
            else {
                $finalWidth = $Width
                $finalHeight = $Width / $ratio
            }

            $finalWidth = $finalWidth - $finalWidth * 15 / 100
            $finalHeight = $finalHeight - $finalHeight * 15 / 100

            $mstscParam += " /w:${finalWidth} /h:${finalHeight}"
        }
        else {
            $mstscParam += ' /f'
        }
        $mstscParam += ' /v:'
        $mstscParam += $ComputerName
        Start-Process -NoNewWindow -FilePath $mstsc -ArgumentList $mstscParam.Trim()
    }
    catch {
        Write-Error "Failed to start RDP session to ${ComputerName}: $_"
        Write-Verbose "Error details: $($_.Exception.Message)"
        throw
    }
}

function Get-EnvironmentVariable {
    Get-Item -Path Env:\
}

function Get-ExportedFunctions {
    try {
        $helper_functions = (Get-Module $PROFILE -ListAvailable | Select-Object -ExpandProperty ExportedCommands).Values.Name -join ', '
        Write-Host 'Profile helper functions: ' -NoNewline; Write-Host $helper_functions -ForegroundColor Green
    }
    catch {
        Write-Error "Error obtaining helper function list: $_"
    }
}

function Open-HistoryFile {
    $editor = if ($null -eq $editor -or [string]::IsNullOrWhiteSpace($editor)) { 'notepad' } else { $editor }
    $historyPath = (Get-PSReadLineOption).HistorySavePath

    if (-not $historyPath) {
        Write-Error "History file path not found."
        return
    }

    if (-not (Test-Path $historyPath)) {
        Write-Error "History file does not exist at the expected path: $historyPath"
        return
    }

    try {
        & $editor $historyPath
    }
    catch {
        Write-Error "Failed to open history file using editor: $editor. Error: $_"
    }
}

function Invoke-StayAlive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 1440)] # Max 24 hours
        [int]$Minutes
    )

    begin {
    }

    process {
        Write-Output ":: screen will be awake for $Minutes minute(s)"
        $myshell = New-Object -com "Wscript.Shell"
        for ($i = 0; $i -lt $Minutes; $i++) {
            Write-Output ":: $($Minutes - $i) Minutes left"
            Start-Sleep -Seconds 60
            $myshell.sendkeys("{F15}")
        }
    }

    end {
    }
}

function Search-DuckDuckGo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Query
    )

    $searchTerm = $Query -join ' '
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchTerm)
    $url = "https://duckduckgo.com/?q=$encodedQuery"

    Start-Process $url
}

function Search-Google {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Query
    )

    $searchTerm = $Query -join ' '
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchTerm)
    $url = "https://www.google.com/search?q=$encodedQuery"

    Start-Process $url
}

function Search-StackOverflow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Query
    )

    $searchTerm = $Query -join ' '
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($searchTerm)
    $url = "https://stackoverflow.com/search?q=$encodedQuery"

    Start-Process $url
}

function Get-LoadedAssembly {
    param(
        $name
    )

    if ($name) {
        [appdomain]::currentdomain.GetAssemblies() | Where-Object Location -Match "$name"
    }
    else {
        [appdomain]::currentdomain.GetAssemblies()
    }
}

function Remove-CommitHistory {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param ()

    # Verify we're in a git repository
    if (-not (Test-Path .git)) {
        throw 'Not in a git repository'
    }

    # Check for uncommitted changes
    $status = git status --porcelain
    if ($status) {
        throw 'You have uncommitted changes. Commit or stash them first.'
    }

    if ($PSCmdlet.ShouldProcess('Git repository', 'Delete all commit history')) {
        Write-Warning 'This will delete ALL commit history. This cannot be undone!'
        $confirmation = Read-Host "Type 'DELETE HISTORY' to confirm"

        if ($confirmation -ne 'DELETE HISTORY') {
            Write-Host 'Operation cancelled'
            return
        }

        # delete all your commit history but keep the code in its current state

        # Checkout
        git checkout --orphan latest_branch

        # Add all the files
        git add -A

        # Commit the changes
        git commit -am 'initial commit'

        # Delete the main/master branch
        git branch -D main

        # Rename the current branch to main
        git branch -m main

        # Finally, force update your repository
        git push -f origin main

        # Add upstream (tracking) reference
        git push --set-upstream origin main
    }
}

function Get-CommitMessage {
    [CmdletBinding()]
    param (
    )

    begin {

    }

    process {
        $uri = 'https://whatthecommit.com/index.txt'
        $randomCommitMessage = Invoke-RestMethod -Method Get -Uri $uri
        $randomCommitMessage.Trim()
    }

    end {

    }
}

function Push-MyStuff {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Message,
        [switch]$UseRandomMessage
    )

    # Show what will be committed
    Write-Host "`nFiles to be committed:" -ForegroundColor Yellow
    git status --short

    # Check for sensitive data patterns
    $sensitivePatterns = @('password', 'api[_-]?key', 'secret', 'token', 'credential')
    $files = git diff --cached --name-only
    foreach ($file in $files) {
        $content = git diff --cached $file
        foreach ($pattern in $sensitivePatterns) {
            if ($content -match $pattern) {
                Write-Warning "Potential sensitive data detected in $file (pattern: $pattern)"
                $continue = Read-Host 'Continue anyway? (y/N)'
                if ($continue -ne 'y') {
                    return
                }
            }
        }
    }

    if (-not $Message -and -not $UseRandomMessage) {
        $Message = Read-Host 'Commit message'
    } elseif ($UseRandomMessage) {
        $Message = Get-CommitMessage
        Write-Host "Using random message: $Message" -ForegroundColor Cyan
    }

    if ($PSCmdlet.ShouldProcess('Git repository', 'Commit and push changes')) {
        git add -A
        git commit -m $Message
        git push
    }
}

function Install-Updates {
    [CmdletBinding()]
    param (
    )
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output ":: This needs to be run as Admin!"
        break
    }

    if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }

    # Install Module
    $isInstalled = Get-Module PSWindowsUpdate -ListAvailable
    if (!($isInstalled)) {
        Install-Module PSWindowsUpdate
    }

    # Import Module
    if (-not (Get-Module PSWindowsUpdate)) {
        Import-Module PSWindowsUpdate
    }

    $logFolder = "$env:TEMP\Install-Updates"

    if (!(Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory | Out-Null
    }

    # Install Updates
    Get-WindowsUpdate -AcceptAll -Download -Install -IgnoreReboot | Out-File "${logFolder}\$(Get-Date -f yyyy-MM-dd)-WindowsUpdate.log"
}
#endregion useful functions

#region Docker Functions
function DockerCommand {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [String[]]$Args
    )
    docker @Args
}

function ListContainers {
    docker ps -a
}

function ListImages {
    docker images
}

function RemoveDanglingImages {
    docker images -f "dangling=true" -q | ForEach-Object {
        docker rmi $_
    }
}

function Clear-DockerResources {
    # Check for CleanStoppedContainers function
    if (Get-Command -Name CleanStoppedContainers -ErrorAction SilentlyContinue) {
        try {
            CleanStoppedContainers
        }
        catch {
            Write-Warning "An error occurred while running CleanStoppedContainers: $_"
        }
    }
    else {
        Write-Host "CleanStoppedContainers function is not available."
    }

    # Check for CleanUntaggedImages function
    if (Get-Command -Name CleanUntaggedImages -ErrorAction SilentlyContinue) {
        try {
            CleanUntaggedImages
        }
        catch {
            Write-Warning "An error occurred while running CleanUntaggedImages: $_"
        }
    }
    else {
        Write-Host "CleanUntaggedImages function is not available."
    }
}

function CleanStoppedContainers {
    Write-Output "`n>>> Deleting stopped containers`n`n"
    docker ps -a --filter "status=exited" -q | ForEach-Object {
        docker rm $_
    }
}

function CleanUntaggedImages {
    Write-Output "`n>>> Deleting untagged images`n`n"
    docker images -q -f dangling=true | ForEach-Object {
        docker rmi $_
    }
}

function KillAllContainers {
    Write-Output "`n>>> Kill all containers`n`n"
    docker ps -q | ForEach-Object {
        docker kill $_
    }
}

function RemoveAllContainers {
    docker ps -a -q | ForEach-Object {
        docker rm $_
    }
}

function StopAllContainers {
    docker ps -a -q | ForEach-Object {
        docker stop $_
    }
}
#endregion Docker Functions

#region PSReadLine
$PSVersion = $PSVersionTable.PSVersion

$PSReadLineOptions = @{
    EditMode                      = "Vi"
    ExtraPromptLineCount          = 1
    MaximumHistoryCount           = 10000
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    BellStyle                     = "None"
}

# PowerShell 7+ specific features - only in interactive sessions with VT support
if ($PSVersion.Major -ge 7) {
    # Check if host supports VT and is interactive
    $supportsVT = $Host.UI.SupportsVirtualTerminal -or $env:WT_SESSION
    $isInteractive = [Environment]::UserInteractive -and (-not [Console]::IsOutputRedirected)

    if ($supportsVT -and $isInteractive) {
        $PSReadLineOptions.PredictionSource = "History"
        $PSReadLineOptions.PredictionViewStyle = "InlineView" # Available in PowerShell 7+
    }
}

Set-PSReadLineOption @PSReadLineOptions

# Key bindings for both PowerShell v5 and v7+
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Alt+d -Function KillWord

# PowerShell 7+ specific key bindings
if ($PSVersion.Major -ge 7) {
    Set-PSReadLineKeyHandler -Chord Ctrl+k -Function CaptureScreen # Available in PS 7+
}

# Check for backward compatibility with PSReadLine module in PowerShell v5
try {
    Set-PSReadLineOption -PredictionSource "History" -ErrorAction Stop
}
catch {
    # Predictions are not available in PowerShell v5, silently handle the error
}

# Don't save sensitive data
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    $sensitive = "password|asplaintext|token|key|secret"
    return ($line -notmatch $sensitive) -and ($line -notmatch "^\s*$") -and ($line -notmatch "^\s*#")
}

# Resolve full path
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+p' -ScriptBlock {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $tokens = $null
    $ast = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)


    foreach ($token in $tokens) {
        $extent = $token.Extent
        if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
            $tokenToChange = $token
            break
        }
    }

    if ($null -ne $tokenToChange) {
        $extent = $tokenToChange.Extent
        $tokenText = $extent.Text

        $pathValue = $tokenToChange.Value
        $resolvedPath = Resolve-Path -Path $pathValue -ErrorAction SilentlyContinue
        if ($resolvedPath) {
            $replacementText = $extent.Text.Replace($pathValue, $resolvedPath.Path)
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset,
                $tokenText.Length,
                $replacementText)
        }
    }
}
#endregion PSReadLine

#region Argument Completers
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
#endregion Argument Completers

#region Aliases
Set-Alias -Name ll -Value Get-ChildItem
#endregion Aliases

#region Misc Settings
# Create SSL/TLS secure channel
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# .NET Core is not respecting the proxy in some cases
[System.AppContext]::SetSwitch("System.Net.Http.UseSocketsHttpHandler", $false)

# This is to satisfy the proxy authentication request
$browser = New-Object System.Net.WebClient
$browser.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
#endregion Misc Settings

#region Git Prompt
$ohMyPosh = Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue
if ($ohMyPosh) {
    $shell = oh-my-posh get shell
    oh-my-posh init $shell | Invoke-Expression
}
#endregion Git Prompt
