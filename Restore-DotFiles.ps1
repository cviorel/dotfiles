[CmdletBinding()]
param (
    [string]$GitRepo = (Get-Location).Path,
    [switch]$BackupExisting,
    [switch]$DryRun
)

# Import configuration
$ConfigPath = "$PSScriptRoot\config.json"
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

    $tempPath = [System.IO.Path]::GetTempPath()
    $logFilePath = Join-Path -Path $tempPath -ChildPath "dotfilesRestore.log"
    Add-Content -Path $logFilePath -Value $logMessage
}

# Function to check if a specific command is available
function Test-Command {
    param (
        [string]$CommandName
    )

    try {
        # Check if the command exists
        Get-Command $CommandName -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to get the VS Code CLI path in a cross-platform way
function Get-VSCodePath {
    # Try to find 'code' in PATH first (works on all platforms)
    $codeCommand = Get-Command 'code' -ErrorAction SilentlyContinue
    if ($codeCommand) {
        return $codeCommand.Source
    }

    # Fallback to Windows-specific path if 'code' is not in PATH
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        $windowsPath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
        if (Test-Path $windowsPath) {
            return $windowsPath
        }
    }

    # If nothing found, return 'code' and let it fail with a clear error
    return 'code'
}

# Determine current platform
$platform = if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
    'windows'
} elseif ($IsLinux) {
    'linux'
} elseif ($IsMacOS) {
    'macos'
} else {
    'windows'  # Default fallback
}

Write-Log "Detected platform: $platform"

# Process each file in the configuration
foreach ($file in $config.files.PSObject.Properties) {
    # Check if this file is platform-specific
    if ($file.Value.platforms -and $file.Value.platforms -notcontains $platform) {
        Write-Log "Skipping $($file.Name) (not available on $platform)" -Level "INFO"
        continue
    }

    $sourcePath = Join-Path $GitRepo $file.Value.destination

    # Get platform-specific destination path
    $destinationPathTemplate = if ($file.Value.source -is [string]) {
        $file.Value.source
    } elseif ($file.Value.source.$platform) {
        $file.Value.source.$platform
    } else {
        Write-Log "No source path defined for $($file.Name) on $platform" -Level "WARNING"
        continue
    }

    # Expand environment variables and tilde
    $destinationPath = [System.Environment]::ExpandEnvironmentVariables($destinationPathTemplate)
    if ($destinationPath -match '^~') {
        $homePath = [System.Environment]::GetFolderPath('UserProfile')
        $destinationPath = $destinationPath -replace '^~', $homePath
    }

    # Get platform-specific binary name
    $binaryName = if ($file.Value.binaryName -is [string]) {
        $file.Value.binaryName
    } elseif ($file.Value.binaryName.$platform) {
        $file.Value.binaryName.$platform
    } else {
        Write-Log "No binary name defined for $($file.Name) on $platform" -Level "WARNING"
        continue
    }

    Write-Log "Processing $($file.Name)..."
    if (Test-Command -CommandName $binaryName) {
        Write-Log "Binary found: $binaryName"

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
                    $vsCodePath = Get-VSCodePath
                    $installedExtensions = & $vsCodePath --list-extensions 2>$null

                    foreach ($extension in $extensionsToInstall) {
                        # Trim whitespace and skip empty lines
                        $extension = $extension.Trim()
                        if ([string]::IsNullOrWhiteSpace($extension)) {
                            continue
                        }

                        # Check if extension is already installed (case-insensitive comparison)
                        $isInstalled = $installedExtensions | Where-Object { $_.Trim() -eq $extension }

                        if (-not $isInstalled) {
                            if ($DryRun) {
                                Write-Log "Would install VSCode extension: $extension"
                            }
                            else {
                                $installOutput = & $vsCodePath --install-extension $extension --force 2>&1
                                # Only log as installed if it wasn't already installed
                                if ($installOutput -notmatch "is already installed") {
                                    Write-Log "Installed VSCode extension: $extension"
                                }
                                else {
                                    Write-Log "VSCode extension already installed: $extension"
                                }
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
                        Copy-Item -Path "$snippetsSource\*" -Destination $snippetsDestination -Recurse -Force
                        Write-Log "Copied VSCode snippets: $snippetsSource -> $snippetsDestination"
                    }
                }
            }
        }
        catch {
            Write-Log "Error processing $($file.Name): $_" -Level "ERROR"
        }
    }
    else {
        Write-Log "Binary not found: $binaryName" -Level "WARNING"
    }
}

Write-Log "Restore process completed."

$tempPath = [System.IO.Path]::GetTempPath()
$logFilePath = Join-Path -Path $tempPath -ChildPath "dotfilesRestore.log"
Write-Host "Log file: $logFilePath"
