
$source = @{
    psCoreProfile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    psProfile     = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    VSCode        = "$env:APPDATA\Code\User\settings.json"
    azDataStudio  = "$env:APPDATA\azuredatastudio\User\settings.json"
    WTerminal     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

$gitRepo = "$env:USERPROFILE\Documents\GitHub\dotfiles"

$output = @()

foreach ($sName in $source.GetEnumerator()) {
    $gitPath = Join-Path -Path $gitRepo -ChildPath $sName.Name
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name Application -Value $sName.Name
    $obj | Add-Member -MemberType NoteProperty -Name Source -Value $sName.Value
    $obj | Add-Member -MemberType NoteProperty -Name Destination -Value $gitPath
    $output += $obj
}

foreach ($item in $output) {
    if ($item.Application -match 'psCoreProfile|psProfile') {
        if (!(Test-Path -Path $item.Source)) {
            New-Item -Path $item.Source -ItemType File -Force
        }
    }

    if (Test-Path -Path $item.Source) {
        $fileName = Resolve-Path -Path $item.Source | Split-Path -Leaf
        Copy-Item -Path "$gitRepo\$($item.Application)\$fileName" -Destination "$($item.Source)" -Force
    }

    if ($item.Application -match 'VSCode') {
        if (Test-Path -Path "$gitRepo\$($item.Application)\extensions.txt") {
            $extensions = Get-Content -Path "$gitRepo\$($item.Application)\extensions.txt"
            $extensions | ForEach-Object { code --install-extension $_ }
        }
    }
}
