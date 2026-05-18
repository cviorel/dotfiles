# Dotfiles Backup and Restore

A cross-platform PowerShell solution for automating the backup and restoration of configuration files (dotfiles) for PowerShell, VSCode, Windows PowerShell, and Windows Terminal. The project consists of two main scripts: [`Backup-DotFiles.ps1`](Backup-DotFiles.ps1) for backing up and [`Restore-DotFiles.ps1`](Restore-DotFiles.ps1) for restoring configuration files.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Backup Configuration Files](#backup-configuration-files)
  - [Restore Configuration Files](#restore-configuration-files)
- [Project Structure](#project-structure)
- [Supported Applications](#supported-applications)
- [Logging](#logging)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project simplifies backing up and restoring configuration files across different environments and platforms (Windows, Linux, macOS). The [`config.json`](config.json) file defines which files to include in backup and restore operations, with platform-specific path resolution and binary detection.

## Features

- **Cross-platform support**: Works on Windows, Linux, and macOS
- **Platform-specific configuration**: Automatically detects the current platform and uses appropriate paths
- **Application detection**: Verifies that applications are installed before attempting backup/restore operations
- **VSCode extensions management**: Automatically exports and installs VSCode extensions
- **VSCode snippets support**: Backs up and restores custom VSCode snippets
- **Dry run mode**: Simulate operations without making actual changes
- **Backup existing files**: Optionally create `.bak` copies before restoring
- **Comprehensive logging**: Detailed logs with timestamps for monitoring and troubleshooting
- **Automatic directory creation**: Creates necessary directories if they don't exist
- **Environment variable expansion**: Supports Windows environment variables (`%USERPROFILE%`, `%APPDATA%`, etc.) and Unix tilde (`~`) expansion

## Requirements

- **PowerShell**: Version 5.0 or later (PowerShell Core 7+ recommended for cross-platform support)
- **Applications**: The applications you want to manage must be installed and accessible via their command-line binaries:
  - PowerShell Core (`pwsh` or `pwsh.exe`)
  - Windows PowerShell (`powershell.exe`) - Windows only
  - Visual Studio Code (`code` or `code.cmd`)
  - Windows Terminal (`wt.exe`) - Windows only

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/cviorel/dotfiles.git
   cd dotfiles
   ```

2. Ensure PowerShell is installed on your system. For cross-platform support, install PowerShell Core 7+.

## Configuration

The [`config.json`](config.json) file defines which configuration files to manage. Each entry includes:

- **`source`**: Platform-specific paths to the original configuration files (supports environment variables and `~`)
- **`destination`**: Relative path within the repository where files are stored
- **`binaryName`**: Platform-specific binary names used to detect if the application is installed
- **`platforms`**: (Optional) Array of platforms where this configuration applies (`windows`, `linux`, `macos`)

### Configuration Structure

```json
{
  "files": {
    "ApplicationName": {
      "source": {
        "windows": "%USERPROFILE%\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1",
        "linux": "~/.config/powershell/Microsoft.PowerShell_profile.ps1",
        "macos": "~/.config/powershell/Microsoft.PowerShell_profile.ps1"
      },
      "destination": "PowerShell/Microsoft.PowerShell_profile.ps1",
      "binaryName": {
        "windows": "pwsh.exe",
        "linux": "pwsh",
        "macos": "pwsh"
      }
    }
  }
}
```

### Current Configuration

The repository currently manages:

- **PowerShell Core**: Profile script (`Microsoft.PowerShell_profile.ps1`)
- **Windows PowerShell**: Profile script (Windows only)
- **VSCode**: Settings, extensions, and snippets
- **Windows Terminal**: Settings (Windows only)

## Usage

### Backup Configuration Files

Run the [`Backup-DotFiles.ps1`](Backup-DotFiles.ps1) script to back up your configuration files:

```powershell
.\Backup-DotFiles.ps1
```

**Parameters:**

- **`-GitRepo`**: Specify a custom repository path (default: current directory)

  ```powershell
  .\Backup-DotFiles.ps1 -GitRepo "C:\path\to\dotfiles"
  ```

- **`-DryRun`**: Simulate the backup process without making any changes

  ```powershell
  .\Backup-DotFiles.ps1 -DryRun
  ```

**What it does:**

- Detects the current platform (Windows, Linux, or macOS)
- Checks if each application is installed by verifying the binary exists
- Copies configuration files from their source locations to the repository
- For VSCode: Exports installed extensions to `vscode/extensions.txt`
- For VSCode: Backs up custom snippets from the `snippets` directory
- Creates necessary directories automatically
- Logs all operations to `dotfilesBackup.log`

### Restore Configuration Files

Run the [`Restore-DotFiles.ps1`](Restore-DotFiles.ps1) script to restore your configuration files:

```powershell
.\Restore-DotFiles.ps1
```

**Parameters:**

- **`-GitRepo`**: Specify a custom repository path (default: current directory)

  ```powershell
  .\Restore-DotFiles.ps1 -GitRepo "C:\path\to\dotfiles"
  ```

- **`-BackupExisting`**: Create `.bak` copies of existing files before overwriting

  ```powershell
  .\Restore-DotFiles.ps1 -BackupExisting
  ```

- **`-DryRun`**: Simulate the restore process without making any changes

  ```powershell
  .\Restore-DotFiles.ps1 -DryRun
  ```

**What it does:**

- Detects the current platform (Windows, Linux, or macOS)
- Checks if each application is installed by verifying the binary exists
- Copies configuration files from the repository to their destination locations
- For VSCode: Installs extensions listed in `vscode/extensions.txt` (skips already installed)
- For VSCode: Restores custom snippets to the snippets directory
- Optionally backs up existing files with `.bak` extension
- Creates necessary directories automatically
- Logs all operations to `dotfilesRestore.log`

## Project Structure

```
dotfiles/
├── Backup-DotFiles.ps1              # Backup script
├── Restore-DotFiles.ps1             # Restore script
├── config.json                      # Configuration file
├── LICENSE                          # MIT License
├── README.md                        # This file
├── PowerShell/                      # PowerShell Core profile
│   └── Microsoft.PowerShell_profile.ps1
├── WindowsPowerShell/               # Windows PowerShell profile
│   └── Microsoft.PowerShell_profile.ps1
├── vscode/                          # VSCode configuration
│   ├── settings.json                # VSCode settings
│   ├── extensions.txt               # List of installed extensions
│   └── snippets/                    # Custom snippets
│       └── powershell.json
├── WindowsTerminal/                 # Windows Terminal configuration
│   └── settings.json
└── bash/                            # Bash configuration files
    ├── .bash_aliases
    ├── .bash_functions
    ├── .bash_logout
    ├── .bashrc
    ├── .colors
    ├── .dircolors
    ├── .gitattributes
    ├── .gitconfig
    ├── .profile
    ├── .screenrc
    ├── .vimrc
    ├── .Xdefaults
    ├── bootstrap.sh
    ├── install-git-prompt.sh
    └── README.md
```

## Supported Applications

| Application        | Windows | Linux | macOS | Notes                                   |
| :----------------- | :-----: | :---: | :---: | :-------------------------------------- |
| PowerShell Core    |    ✓    |   ✓   |   ✓   | Requires `pwsh` binary                  |
| Windows PowerShell |    ✓    |   ✗   |   ✗   | Windows-only, requires `powershell.exe` |
| Visual Studio Code |    ✓    |   ✓   |   ✓   | Includes settings, extensions, snippets |
| Windows Terminal   |    ✓    |   ✗   |   ✗   | Windows-only, requires `wt.exe`         |

## Logging

Both scripts generate detailed log files stored in the system's temporary directory:

- **Backup log**: `dotfilesBackup.log`
- **Restore log**: `dotfilesRestore.log`

**Log location by platform:**

- **Windows**: `%TEMP%\dotfilesBackup.log` or `%TEMP%\dotfilesRestore.log`
- **Linux/macOS**: `/tmp/dotfilesBackup.log` or `/tmp/dotfilesRestore.log`

**Log format:**

```
[2026-05-18 20:24:15] [INFO] Detected platform: windows
[2026-05-18 20:24:15] [INFO] Processing PowerShell...
[2026-05-18 20:24:15] [INFO] Binary found: pwsh.exe
[2026-05-18 20:24:15] [INFO] Copied: C:\Users\...\Microsoft.PowerShell_profile.ps1 -> PowerShell\Microsoft.PowerShell_profile.ps1
```

The log file path is displayed at the end of each script execution.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE) file for details.
