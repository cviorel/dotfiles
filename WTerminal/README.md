# Dotfiles Repository

This repository contains a collection of dotfiles and scripts for setting up and customizing various development environments. It includes configurations for PowerShell, Visual Studio Code, Windows Terminal, and more.

## Structure

- **.gitattributes & .gitconfig**: Git configuration and attributes for handling repository content.
- **azDataStudio/**: Settings for Azure Data Studio.
- **Backup-DotFiles.ps1 & Restore-DotFiles.ps1**: Scripts for backing up and restoring dotfiles.
- **bash/**: Bash configurations and scripts, including aliases, functions, and settings for tools like Vim and screen.
- **LICENSE**: The MIT License under which this repository is made available.
- **psCoreProfile/** & **psProfile/**: PowerShell profiles for different PowerShell environments.
- **VSCode/**: Visual Studio Code settings, extensions list, and snippets for PowerShell.
- **WTerminal/**: Settings for Windows Terminal.

## Features

- **PowerShell Profiles**: Custom PowerShell profiles for enhancing the shell experience with useful functions and aliases.
- **Visual Studio Code Customization**: A curated list of extensions and custom settings to optimize the development experience in VS Code.
- **Bash Enhancements**: Enhancements for Bash including aliases, functions, and prompt customization for a better terminal experience.
- **Windows Terminal Settings**: Custom settings for Windows Terminal to improve usability and appearance.

## Usage

### Backup and Restore Dotfiles

- **Backup**: Run `Backup-DotFiles.ps1` to backup current settings.
- **Restore**: Run `Restore-DotFiles.ps1` with the appropriate parameters to restore settings from this repository.

### Applying Bash Configurations

Execute the `bootstrap.sh` script in the `bash/` directory to apply bash configurations.

### Setting Up Visual Studio Code

Install the extensions listed in `VSCode/extensions.txt` and apply the settings from `VSCode/settings.json` for an optimized VS Code setup.

### Configuring Windows Terminal

Apply the settings from `WTerminal/settings.json` to customize the appearance and behavior of Windows Terminal.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
