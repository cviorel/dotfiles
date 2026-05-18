[CmdletBinding()]
param (
    [string]$GitRepo = (Get-Location).Path,
    [switch]$DryRun
)

# Import configuration
$ConfigPath = "$PSScriptRoot\config.json"
$config = Get-Content $ConfigPath | ConvertFrom-Json

# Logging function
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage

    try {
        $tempPath = [System.IO.Path]::GetTempPath()
        $logFilePath = Join-Path -Path $tempPath -ChildPath 'dotfilesBackup.log'
        Add-Content -Path $logFilePath -Value $logMessage -ErrorAction Stop
    } catch {
        Write-Warning "Failed to write to log file: $_"
    }
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

# Process each file in the configuration
foreach ($file in $config.files.PSObject.Properties) {
    $sourcePath = [System.Environment]::ExpandEnvironmentVariables($file.Value.source)
    $destinationPath = Join-Path $GitRepo $file.Value.destination
    $binaryName = $file.Value.binaryName

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
                $extensionsPath = Join-Path (Split-Path $destinationPath -Parent) "extensions.txt"
                if ($DryRun) {
                    Write-Log "Would export VSCode extensions to: $extensionsPath"
                }
                else {
                    $vsCodePath = Get-VSCodePath
                    & $vsCodePath --list-extensions | Out-File -FilePath $extensionsPath -Force
                    Write-Log "Exported VSCode extensions to: $extensionsPath"
                }

                # Copy VSCode snippets
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

Write-Log "Backup process completed."

$tempPath = [System.IO.Path]::GetTempPath()
$logFilePath = Join-Path -Path $tempPath -ChildPath "dotfilesBackup.log"
Write-Host "Log file: $logFilePath"
