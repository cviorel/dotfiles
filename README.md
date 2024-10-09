# Dotfiles Backup and Restore Scripts

This repository contains two PowerShell scripts for managing your dotfiles:

1. `Backup-DotFiles.ps1`: Backs up specified files to a Git repository.
2. `Restore-DotFiles.ps1`: Restores files from the Git repository to their original locations.

## Prerequisites

- PowerShell 5.1 or later
- Git (for managing the dotfiles repository)
- Visual Studio Code (for handling VSCode extensions and snippets)

## Configuration

Both scripts use a `config.json` file to specify which files should be backed up or restored. The config file should be in the same directory as the scripts. Here's an example structure:

```json
{
  "files": {
    "PowerShell": {
      "source": "%USERPROFILE%\\Documents\\WindowsPowerShell\\Microsoft.PowerShell_profile.ps1",
      "destination": "PowerShell\\Microsoft.PowerShell_profile.ps1"
    },
    "VSCode": {
      "source": "%APPDATA%\\Code\\User\\settings.json",
      "destination": "VSCode\\settings.json"
    }
  }
}
```

## Backup-DotFiles.ps1

This script backs up specified files to a Git repository.

### Parameters

- `-ConfigPath`: Path to the configuration file (default: `$PSScriptRoot\config.json`)
- `-GitRepo`: Path to the Git repository where files will be backed up (default: `D:\GitHub\dotfiles`)
- `-DryRun`: If specified, the script will only show what would be done without making any changes

### Usage

```powershell
.\Backup-DotFiles.ps1 -GitRepo "C:\Users\YourUsername\dotfiles"
```

To perform a dry run:

```powershell
.\Backup-DotFiles.ps1 -DryRun
```

## Restore-DotFiles.ps1

This script restores files from the Git repository to their original locations.

### Parameters

- `-ConfigPath`: Path to the configuration file (default: `$PSScriptRoot\config.json`)
- `-GitRepo`: Path to the Git repository containing the backed-up files (default: `D:\GitHub\dotfiles`)
- `-BackupExisting`: If specified, creates a backup of existing files before overwriting
- `-DryRun`: If specified, the script will only show what would be done without making any changes

### Usage

```powershell
.\Restore-DotFiles.ps1 -GitRepo "C:\Users\YourUsername\dotfiles" -BackupExisting
```

To perform a dry run:

```powershell
.\Restore-DotFiles.ps1 -DryRun
```

## Special Handling for VSCode

Both scripts have special handling for Visual Studio Code:

- They export/import the list of installed extensions.
- They backup/restore VSCode snippets.

## Logging

Both scripts create log files (`backup.log` and `restore.log`) in the same directory as the scripts, providing a detailed record of operations performed.

## Examples

### Backing up dotfiles

```powershell
# Backup dotfiles to the default Git repository
.\Backup-DotFiles.ps1

# Backup dotfiles to a specific Git repository
.\Backup-DotFiles.ps1 -GitRepo "C:\Users\YourUsername\dotfiles"

# Perform a dry run to see what would be backed up
.\Backup-DotFiles.ps1 -DryRun
```

### Restoring dotfiles

```powershell
# Restore dotfiles from the default Git repository
.\Restore-DotFiles.ps1

# Restore dotfiles from a specific Git repository and backup existing files
.\Restore-DotFiles.ps1 -GitRepo "C:\Users\YourUsername\dotfiles" -BackupExisting

# Perform a dry run to see what would be restored
.\Restore-DotFiles.ps1 -DryRun
```

## Notes

- Always review the changes before committing them to your dotfiles repository.
- Be cautious when restoring files, especially if you've made local changes that haven't been backed up.
- Use the `-DryRun` parameter to preview changes before applying them.
