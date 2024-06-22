param (
    [string]$gitRepo = "D:\GitHub\dotfiles",
    [string]$documentsLocation = [Environment]::GetFolderPath("MyDocuments")
)

$source = @{
    psCoreProfile = "$documentsLocation\PowerShell\Microsoft.PowerShell_profile.ps1"
    psProfile     = "$documentsLocation\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    VSCode        = "$env:APPDATA\Code\User\settings.json"
    azDataStudio  = "$env:APPDATA\azuredatastudio\User\settings.json"
    WTerminal     = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
}

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
    Write-Host "Processing $($item.Application)..."
    try {
        if (Test-Path -Path $($item.Destination)) {
            Remove-Item -Path $($item.Destination) -Recurse -Force -ErrorAction Stop
        }
        New-Item -Path $($item.Destination) -ItemType Directory -ErrorAction Stop
        Copy-Item -Path $($item.Source) -Destination $($item.Destination) -ErrorAction Stop
        if ($item.Application -eq 'VSCode') {
            code --list-extensions | Out-File -Path "$($item.Destination)\extensions.txt"
            $vscodeRoot = $($item.Source) | Split-Path -Parent
            $snipFolder = "$vscodeRoot\snippets"
            if (Test-Path -Path $snipFolder) {
                Copy-Item -Path $snipFolder -Destination $($item.Destination) -Recurse -ErrorAction Stop
            }
        }
        Write-Host "Successfully processed $($item.Application)."
    }
    catch {
        Write-Host "Error processing $($item.Application): $_"
    }
}
