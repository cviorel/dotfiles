# Dotfiles Backup and Restore

This project provides a PowerShell solution for automating the backup and restoration of configuration files (dotfiles) for various applications like PowerShell, VSCode, Azure Data Studio, and Windows Terminal. The project consists of two main scripts: `Backup-DotFiles.ps1` for backing up and `Restore-DotFiles.ps1` for restoring the configuration files.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Logging](#logging)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Overview

This project makes it easy to back up and restore your configuration files across different environments. The `config.json` file specifies which files to include in the backup and restore operations, ensuring consistency and ease of management.

## Features

- Backup and restore configuration files for PowerShell, VSCode, Azure Data Studio, and Windows Terminal.
- Dry run option to simulate actions without making actual changes.
- Logs actions and errors for easy monitoring and troubleshooting.
- Supports VSCode extensions backup and restoration.
- Creates necessary directories if they do not exist.

## Requirements

- PowerShell 5.0 or later.
- Required applications (e.g., VSCode) should be installed if their configurations are managed through this project.

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/cviorel/dotfiles.git
   cd dotfiles
   ```

2. Ensure PowerShell is installed on your system.

## Configuration

Edit the `config.json` file to specify the paths to the configuration files you wish to back up or restore. Each entry in the JSON file consists of a `source` path pointing to the actual location of the file and a `destination` which indicates where the file should be stored inside the backup repository.

Example configuration for `config.json`:

```json
{
    "files": {
        "PowerShell": {
            "source": "%USERPROFILE%\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1",
            "destination": "PowerShell\\Microsoft.PowerShell_profile.ps1"
        },
        ...
    }
}
```

## Usage

### Backup Configuration Files

Run the `Backup-DotFiles.ps1` script to back up your configuration files:

```PowerShell
.\Backup-DotFiles.ps1
```

- **Dry Run:** To simulate the backup process without making any changes:

  ```PowerShell
  .\Backup-DotFiles.ps1 -DryRun
  ```

### Restore Configuration Files

Run the `Restore-DotFiles.ps1` script to restore your configuration files:

```PowerShell
.\Restore-DotFiles.ps1
```

- **Backup Existing Files:** To backup existing files before restoring new ones:

  ```PowerShell
  .\Restore-DotFiles.ps1 -BackupExisting
  ```

- **Dry Run:** To simulate the restore process without making any changes:

  ```PowerShell
  .\Restore-DotFiles.ps1 -DryRun
  ```

## Logging

Both scripts generate log files stored in the system's temporary directory:

- `dotfilesBackup.log` for backup operations.
- `dotfilesRestore.log` for restore operations.

These logs contain timestamps and messages detailing each action taken or any issues encountered.

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
