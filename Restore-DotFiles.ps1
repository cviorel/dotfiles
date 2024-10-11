[CmdletBinding()]
param (
    [string]$ConfigPath = "$PSScriptRoot\config.json",
    [string]$GitRepo = "D:\\GitHub\\dotfiles",
    [switch]$BackupExisting,
    [switch]$DryRun
)

# Import configuration
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Logging function
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path "$PSScriptRoot\restore.log" -Value $logMessage
}

# Process each file in the configuration
foreach ($file in $config.files.PSObject.Properties) {
    $sourcePath = Join-Path $GitRepo $file.Value.destination
    $destinationPath = [System.Environment]::ExpandEnvironmentVariables($file.Value.source)

    Write-Log "Processing $($file.Name)..."

    try {
        # Check if source file exists
        if (-not (Test-Path $sourcePath)) {
            Write-Log "Source file not found: $sourcePath" -Level "WARNING"
            continue
        }

        # Create destination directory if it doesn't exist
        $destinationDir = Split-Path $destinationPath -Parent
        if (-not (Test-Path $destinationDir)) {
            if (-not $DryRun) {
                New-Item -Path $destinationDir -ItemType Directory -Force | Out-Null
            }
            Write-Log "Created directory: $destinationDir"
        }

        # Backup existing file if requested
        if ($BackupExisting -and (Test-Path $destinationPath)) {
            $backupPath = "$destinationPath.bak"
            if ($DryRun) {
                Write-Log "Would backup: $destinationPath -> $backupPath"
            }
            else {
                Copy-Item -Path $destinationPath -Destination $backupPath -Force
                Write-Log "Backed up: $destinationPath -> $backupPath"
            }
        }

        # Copy file
        if ($DryRun) {
            Write-Log "Would copy: $sourcePath -> $destinationPath"
        }
        else {
            Copy-Item -Path $sourcePath -Destination $destinationPath -Force
            Write-Log "Copied: $sourcePath -> $destinationPath"
        }

        # Handle VSCode extensions
        if ($file.Name -eq 'VSCode') {
            $extensionsPath = Join-Path (Split-Path $sourcePath -Parent) "extensions.txt"
            if (Test-Path $extensionsPath) {
                $extensionsToInstall = Get-Content $extensionsPath
                $installedExtensions = code --list-extensions

                foreach ($extension in $extensionsToInstall) {
                    if ($installedExtensions -notcontains $extension) {
                        if ($DryRun) {
                            Write-Log "Would install VSCode extension: $extension"
                        }
                        else {
                            code --install-extension $extension --force
                            Write-Log "Installed VSCode extension: $extension"
                        }
                    }
                    else {
                        Write-Log "VSCode extension already installed: $extension"
                    }
                }
            }

            # Restore VSCode snippets
            $snippetsSource = Join-Path (Split-Path $sourcePath -Parent) "snippets"
            $snippetsDestination = Join-Path (Split-Path $destinationPath -Parent) "snippets"
            if (Test-Path $snippetsSource) {
                if ($DryRun) {
                    Write-Log "Would copy VSCode snippets: $snippetsSource -> $snippetsDestination"
                }
                else {
                    Copy-Item -Path $snippetsSource -Destination $snippetsDestination -Recurse -Force
                    Write-Log "Copied VSCode snippets: $snippetsSource -> $snippetsDestination"
                }
            }
        }
    }
    catch {
        Write-Log "Error processing $($file.Name): $_" -Level "ERROR"
    }
}

Write-Log "Restore process completed."
