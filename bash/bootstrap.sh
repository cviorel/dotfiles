#!/bin/bash

set -e

cd ~

DOTFILES_REPO="${HOME}/dotfiles"
GIT_CONTRIB_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion"

# Check if wget or curl is available
if ! command -v wget &>/dev/null && ! command -v curl &>/dev/null; then
    echo "Error: wget or curl is required to download git-completion scripts."
    exit 1
fi

# Create necessary directories
mkdir -p "${HOME}/bin" "${HOME}/.config/git"

# Download git completion scripts
if command -v wget &>/dev/null; then
    wget "${GIT_CONTRIB_URL}/git-completion.bash" --no-check-certificate -q -O "${HOME}/bin/git-completion.bash"
    wget "${GIT_CONTRIB_URL}/git-prompt.sh" --no-check-certificate -q -O "${HOME}/bin/git-prompt.sh"
elif command -v curl &>/dev/null; then
    curl "${GIT_CONTRIB_URL}/git-completion.bash" -L -s -o "${HOME}/bin/git-completion.bash"
    curl "${GIT_CONTRIB_URL}/git-prompt.sh" -L -s -o "${HOME}/bin/git-prompt.sh"
fi

# Create symlinks for dotfiles
for dotfile in .?*; do
    case "${dotfile}" in
    .. | .git | .gitmodules)
        # ignore
        continue
        ;;
    *)
        # symlink
        ln -sfni "${PWD}/${dotfile}" "${HOME}"
        echo "Created symlink for ${dotfile}"
        ;;
    esac
done

echo "Bootstrap completed successfully."
