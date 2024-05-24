[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

#region Set Editor
$vscode = $(Get-Command code -ErrorAction Ignore | Select-Object -ExpandProperty Source)
$vim = $(Get-Command vim -ErrorAction Ignore | Select-Object -ExpandProperty Source)

if ($IsWindows) {
    if (!([string]::IsNullOrEmpty($vscode))) {
        $editor = $vscode
    }
    else {
        $editor = $vim
    }
}

if ($IsLinux -or $IsMacOS) {
    $editor = $env:EDITOR
}
#endregion Set Editor

#region useful functions
function Get-MessageOfTheDay {
    $msg = @"
If life gives you lemons, squirt someone in the eye. 😂
Doing nothing is hard; you never know when you're done. 🤣
I'm not lazy, just very relaxed. 😜
Always remember you're unique, just like everyone else. 🙈
I'm not clumsy, it's just the floor hates me, the tables and chairs are bullies, and the wall gets in the way. 😉
Life is short. If you can't laugh at yourself, call me...I'll laugh at you. 😅
To be old and wise, you must first be young and stupid. 🤪
I'm not arguing, I'm simply explaining why I'm right. 🤔
With great power comes an even greater electricity bill. 😇
Money talks...but all mine ever says is goodbye. 😍
I would lose weight, but I hate losing. 🥳
If you think nothing is impossible, try slamming a revolving door. 😎
I'd agree with you but then we'd both be wrong. 👻
My wallet is like an onion, opening it makes me cry. 💩
I didn't fall, I'm just spending some quality time with the floor. 👽
I'm not addicted to reading, I can quit as soon as I finish one more chapter. 🤖
Why is 'abbreviation' such a long word? 🎃
I'm an excellent housekeeper. Every time I get a divorce, I keep the house. 😺
I used to think I was indecisive, but now I'm not too sure. 🦄
My imaginary friend thinks he has problems. 🐉
I'm not short, I'm just more down to earth than other people. 🍀
I'm so good at sleeping, I can do it with my eyes closed. 🌈
If I won the award for laziness, I would send someone to pick it up for me. ⚡
Some days, the best thing about my job is that the chair spins. 🍉
I'm not bossy, I just know exactly what you should be doing. 🍔
I'm not weird, I'm a limited edition. 🍕
I'm not arguing, I'm simply trying to explain why I'm right. 🍺
If life gives you lemons, squirt someone in the eye. 🎮
Doing nothing is hard; you never know when you're done. 🚀
I'm not lazy, just very relaxed. 💡
Always remember you're unique, just like everyone else. 🎁
I'm not clumsy, it's just the floor hates me, the tables and chairs are bullies, and the wall gets in the way. 💰
Life is short. If you can't laugh at yourself, call me...I'll laugh at you. 🧭
To be old and wise, you must first be young and stupid. 🧲
I'm not arguing, I'm simply explaining why I'm right. 🔮
With great power comes an even greater electricity bill. 🛸
Money talks...but all mine ever says is goodbye. 🧨
I would lose weight, but I hate losing. 🔒
If you think nothing is impossible, try slamming a revolving door. 🔑
I'd agree with you but then we'd both be wrong. 🕰
My wallet is like an onion, opening it makes me cry. 🌙
I didn't fall, I'm just spending some quality time with the floor. 🌟
I'm not addicted to reading, I can quit as soon as I finish one more chapter. 🌍
Why is 'abbreviation' such a long word? 🌹
I'm an excellent housekeeper. Every time I get a divorce, I keep the house. 🍄
I used to think I was indecisive, but now I'm not too sure. 🌻
My imaginary friend thinks he has problems. 🌊
I'm not short, I'm just more down to earth than other people. ⛄
If you can't live without me, why aren't you dead yet? 🔥
I'm so good at sleeping, I can do it with my eyes closed. 🎈
If I won the award for laziness, I would send someone to pick it up for me. 🧸
Some days, the best thing about my job is that the chair spins. 📚
I'm not bossy, I just know exactly what you should be doing. 🔔
I'm not weird, I'm a limited edition. 🎧
I'm not arguing, I'm simply trying to explain why I'm right. 🎤
If life gives you lemons, squirt someone in the eye. 🎵
Doing nothing is hard; you never know when you're done. 🍿
I'm not lazy, just very relaxed. 🍫
Always remember you're unique, just like everyone else. 🥑
I'm not clumsy, it's just the floor hates me, the tables and chairs are bullies, and the wall gets in the way. 🍓
Life is short. If you can't laugh at yourself, call me...I'll laugh at you. 🏀
To be old and wise, you must first be young and stupid. 🚗
I'm not arguing, I'm simply explaining why I'm right. ✈️
With great power comes an even greater electricity bill. 🚤
Money talks...but all mine ever says is goodbye. 🛁
I would lose weight, but I hate losing. 🏖
If you think nothing is impossible, try slamming a revolving door. ⛺
I'd agree with you but then we'd both be wrong. 🏰
My wallet is like an onion, opening it makes me cry. 🛡
I didn't fall, I'm just spending some quality time with the floor. 🔑
I'm not addicted to reading, I can quit as soon as I finish one more chapter. 🎨
Why is 'abbreviation' such a long word? 🧵
I'm an excellent housekeeper. Every time I get a divorce, I keep the house. 🧶
I used to think I was indecisive, but now I'm not too sure. 📸
My imaginary friend thinks he has problems. 🔍
I'm not short, I'm just more down to earth than other people. 🚀
If you can't live without me, why aren't you dead yet? 🌵
I'm so good at sleeping, I can do it with my eyes closed. 🎂
If I won the award for laziness, I would send someone to pick it up for me. 🏆
Some days, the best thing about my job is that the chair spins. 🍦
I'm not bossy, I just know exactly what you should be doing. 🍭
I'm not weird, I'm a limited edition. 🍬
I'm not arguing, I'm simply trying to explain why I'm right. 🥥
If life gives you lemons, squirt someone in the eye. 🍍
Doing nothing is hard; you never know when you're done. 🥦
I'm not lazy, just very relaxed. 🍳
Always remember you're unique, just like everyone else. 🥖
I'm not clumsy, it's just the floor hates me, the tables and chairs are bullies, and the wall gets in the way. 🧀
Life is short. If you can't laugh at yourself, call me...I'll laugh at you. 🍷
To be old and wise, you must first be young and stupid. 🍹
I'm not arguing, I'm simply explaining why I'm right. 🥃
With great power comes an even greater electricity bill. 🍻
Money talks...but all mine ever says is goodbye. 🧉
I would lose weight, but I hate losing. 🎱
If you think nothing is impossible, try slamming a revolving door. 🛴
I'd agree with you but then we'd both be wrong. 🎡
My wallet is like an onion, opening it makes me cry. 🎢
I didn't fall, I'm just spending some quality time with the floor. 🎠
I'm not addicted to reading, I can quit as soon as I finish one more chapter. 🏂
Why don't scientists trust atoms? Because they make up everything! 😄
I'm reading a book about anti-gravity. It's impossible to put down! 📚
Why did the scarecrow win an award? Because he was outstanding in his field! 🌾
Why don't skeletons fight each other? They don't have the guts! 💀
I used to be a baker, but I couldn't make enough dough. 🥖
Why did the bicycle fall over? Because it was two-tired! 🚲
What do you call a bear with no teeth? A gummy bear! 🐻
Why did the tomato turn red? Because it saw the salad dressing! 🍅
I'm on a seafood diet. I see food and I eat it! 🍣
Why don't eggs tell jokes? Because they might crack up! 🥚

"@
    $lines = $msg -split "`n"
    $randomLine = $lines | Get-Random
    [Environment]::NewLine + $randomLine + [Environment]::NewLine
}

function Clear-History {
    $histFile = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path -Path $histFile) {
        Remove-Item -Path $histFile -Force -ErrorAction SilentlyContinue
    }
    Write-Output "History file was deleted!"
}

function Get-CustomDirectory {
    [CmdletBinding()]
    [OutputType([String])]
    Param (
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        $Path = $PWD.Path
    )

    Begin {
        # Custom directories as a HashTable
        $CustomDirectories = @{

            $env:TEMP                    = 'Temp'
            $env:APPDATA                 = 'AppData'
            "$env:USERPROFILE"           = '~'
            "$env:USERPROFILE\Desktop"   = 'Desktop'
            "$env:USERPROFILE\Documents" = 'MyDocuments'
            "$env:USERPROFILE\Downloads" = 'Downloads'
        }
    }
    Process {
        Foreach ($Item in $Path) {
            $Match = ($CustomDirectories.GetEnumerator().name | Where-Object { $Item -eq "$_" -or $Item -like "$_*" } |`
                    Select-Object @{n = 'Directory'; e = { $_ } }, @{n = 'Length'; e = { $_.length } } | Sort-Object Length -Descending | Select-Object -First 1).directory
            If ($Match) {
                [String]($Item -replace [regex]::Escape($Match), $CustomDirectories[$Match])
            }
            ElseIf ($pwd.Path -ne $Item) {
                $Item
            }
            Else {
                $pwd.Path
            }
        }
    }
    End {
    }
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
    <#
    .SYNOPSIS
    Equivalent of NIX tail -f

    .DESCRIPTION
    Will monitor any kind of text readable log and show changes in real time

    .EXAMPLE
    Get-Tail c:\somelog.log
    #>
    [CmdletBinding()]Param(
        [String]$FilePath
    )

    if (![string]::IsNullOrEmpty($FilePath)) {
        Get-Content -Path "$FilePath" -Wait
    }
    else {
        'You did not select a file.'
    }
}

function Generate-Password {
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
    PS> Generate-Password -Size 12 -CharSets ULNS -Exclude "OLIoli01"

    This would generate a 12 characters long password that does not contain the characters OLIoli01

    .EXAMPLE
    PS> 1..10 | ForEach-Object { Generate-Password -Size 25 -CharSets ULNS }

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
            $Global:TokenSets = @{
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
            #$Width = $res.Width - $res.Width * 15 / 100
            #$Height = $res.Height - $res.Height * 15 / 100
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
    & $editor (Get-PSReadLineOption | Select-Object -ExpandProperty HistorySavePath)
}

function Invoke-StayAlive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
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

function Duck {
    Start-Process "https://duckduckgo.com/?q=$args"
}

function Google {
    Start-Process "https://www.google.com/search?q=$args"
}

function StackOverflow {
    Start-Process "https://www.stackoverflow.com/search?q=$args"
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
    [CmdletBinding()]
    param (

    )

    begin {

    }

    process {
        # delete all your commit history but keep the code in its current state

        # Checkout
        git checkout --orphan latest_branch

        # Add all the files
        git add -A

        # Commit the changes
        git commit -am "initial commit"

        # Delete the main/master branch
        git branch -D main

        # Rename the current branch to main
        git branch -m main

        # Finally, force update your repository
        git push -f origin main

        # Add upstream (tracking) reference
        git push --set-upstream origin main
    }

    end {

    }
}

function Get-CommitMessage {
    [CmdletBinding()]
    param (
    )

    begin {

    }

    process {
        $uri = 'http://whatthecommit.com/index.txt'
        $randomCommitMessage = Invoke-RestMethod -Method Get -Uri $uri
        $randomCommitMessage.Trim()
    }

    end {

    }
}

function Push-MyStuff {
    [CmdletBinding()]
    param (
    )

    $message = Get-CommitMessage
    git add -A
    git commit -a -m $message
    git push
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
    docker $args
}

function ListContainers {
    docker ps -a
}

function ListImages {
    docker images
}

function RemoveDanglingImages {
    $(docker images -f "dangling=true" -q) | ForEach-Object {
        docker rmi $_
    }
}

function CleanDocker {
    CleanStoppedContainers || $true
    CleanUntaggedImages
}

function CleanStoppedContainers {
    Write-Output "`n>>> Deleting stopped containers`n`n"
    $(docker ps -a --filter "status=exited" -q) | ForEach-Object {
        docker rm $_
    }
}

function CleanUntaggedImages {
    Write-Output "`n>>> Deleting untagged images`n`n"
    $(docker images -q -f dangling=true) | ForEach-Object {
        docker rmi $_
    }
}

function KillAllContainers {
    Write-Output "`n>>> Kill all containers`n`n"
    docker kill $(docker ps -q)
}

function RemoveAllContainers {
    docker rm $(docker ps -a -q)
}

function StopAllContainers {
    docker stop $(docker ps -a -q)
}
#endregion Docker Functions

#region Prompt
function Prompt_DBATools {
    Write-Host "[" -NoNewline
    Write-Host (Get-Date -Format "HH:mm:ss") -ForegroundColor Gray -NoNewline

    try {
        $history = Get-History -ErrorAction Ignore
        if ($history) {
            Write-Host "][" -NoNewline
            if (([System.Management.Automation.PSTypeName]'Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty').Type) {
                Write-Host ([Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime)) -ForegroundColor Gray -NoNewline
            }
            else {
                Write-Host ($history[-1].EndExecutionTime - $history[-1].StartExecutionTime) -ForegroundColor Gray -NoNewline
            }
        }
    }
    catch { }
    Write-Host "] $($executionContext.SessionState.Path.CurrentLocation.ProviderPath)" -NoNewline
    "> "
}

function Prompt {
    Write-Host "I " -NoNewline; Write-Host "$([char]9829) " -ForegroundColor Red -NoNewline; Write-Host "PS " -NoNewline
    Write-Host $(Get-CustomDirectory) -ForegroundColor Green  -NoNewline
    Write-Host " >_" -NoNewline -ForegroundColor Yellow
    return " "
}
#endregion Prompt

#region PSReadLine
$PSReadLineOptions = @{
    EditMode                      = "Vi"
    ExtraPromptLineCount          = 1
    MaximumHistoryCount           = 10000
    HistoryNoDuplicates           = $true
    HistorySearchCursorMovesToEnd = $true
    BellStyle                     = "None"
    PredictionSource              = "History"
    PredictionViewStyle           = "InlineView" # ListView
}
Set-PSReadLineOption @PSReadLineOptions

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Chord Alt+d -Function KillWord
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function CaptureScreen

# Don't save sensitive data
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    $sensitive = "password|asplaintext|token|key|secret"
    return ($line -notmatch $sensitive)
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

#region PS Drives
$psDrives = Get-PSDrive

# Create drives
if ($psDrives.Name -notcontains "Documents") {
    if (Test-Path -Path "$env:USERPROFILE\Documents") {
        $null = New-PSDrive -Name Documents -PSProvider FileSystem -Scope Global -Root "$env:USERPROFILE\Documents"
    }
}
if ($psDrives.Name -notcontains "Downloads") {
    if (Test-Path -Path "$env:USERPROFILE\Downloads") {
        $null = New-PSDrive -Name Downloads -PSProvider FileSystem -Scope Global -Root "$env:USERPROFILE\Downloads"
    }
}
if ($psDrives.Name -notcontains "OneDrive") {
    if (Test-Path -Path "$env:USERPROFILE\OneDrive") {
        $null = New-PSDrive -Name OneDrive -PSProvider FileSystem -Scope Global -Root "$env:USERPROFILE\OneDrive"
    }
}
if ($psDrives.Name -notcontains "Presentations") {
    if (Test-Path -Path "$env:USERPROFILE\OneDrive\Presentations") {
        $null = New-PSDrive -Name Presentations -PSProvider FileSystem -Scope Global -Root "$env:USERPROFILE\OneDrive\Presentations"
    }
}
#endregion PS Drives

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

#region Modules
#region posh-git
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git
}
#endregion posh-git

#region Docker completion
if (Get-Command docker) {
    if (Get-Module DockerCompletion -ListAvailable) {
        Import-Module DockerCompletion
    }
}
#endregion Docker completion
#endregion Modules

oh-my-posh init pwsh --config "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\powerlevel10k_lean.omp.json" | Invoke-Expression
