$documentsLocation = [Environment]::GetFolderPath("MyDocuments")

Start-Transcript -Path "$documentsLocation\Restore-DotFiles_$(Get-Date -Format `"yyyyMMdd_hhmm`").txt"

$source = @{
    psCoreProfile = "$documentsLocation\PowerShell\Microsoft.PowerShell_profile.ps1"
    psProfile     = "$documentsLocation\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    VSCode        = "$env:APPDATA\Code\User\settings.json"
    azDataStudio  = "$env:APPDATA\azuredatastudio\User\settings.json"
    WTerminal     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

$gitRepo = $PSScriptRoot

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
    if ($item.Application -match 'psCoreProfile|psProfile|VSCode|azDataStudio') {
        if (!(Test-Path -Path $item.Source)) {
            Write-Output ":: Creating profile for $($item.Application) -> $($item.Source)"
            New-Item -Path $item.Source -ItemType File -Force
        }
    }

    $fileName = Resolve-Path -Path $item.Source | Split-Path -Leaf

    if (Test-Path -Path $item.Source) {
        Write-Output ":: Copying $gitRepo\$($item.Application)\$fileName -> $($item.Source)"
        Copy-Item -Path "$gitRepo\$($item.Application)\$fileName" -Destination "$($item.Source)" -Force
    }

    if ($item.Application -eq 'VSCode') {
        $vscodeRoot = $($item.Source) | Split-Path -Parent

        # Install snippets
        if (Test-Path -Path "$gitRepo\$($item.Application)\snippets") {
            Write-Output ":: Copying snippets from $gitRepo\$($item.Application)\snippets -> $vscodeRoot"
            Copy-Item -Path "$gitRepo\$($item.Application)\snippets" -Destination "$vscodeRoot" -Recurse -Force
        }

        # Install extensions
        if (Test-Path -Path "$gitRepo\$($item.Application)\extensions.txt") {
            Write-Output ":: Installing VSCode extensions"
            $extensionsToInstall = Get-Content -Path "$gitRepo\$($item.Application)\extensions.txt"
            $installedExtensions = code --list-extensions

            foreach ($extension in $extensionsToInstall) {
                if ($installedExtensions -notcontains $extension) {
                    Write-Output ":: Installing extension: $extension"
                    code --install-extension $extension --force
                }
                else {
                    Write-Output ":: Extension $extension is already installed."
                }
            }
        }
    }
}

Stop-Transcript
