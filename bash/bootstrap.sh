#!/bin/bash

cd ~

DOTFILES_REPO="${HOME}/dotfiles"
GIT_CONTRIB_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion"

[ ! -d "${HOME}/bin" ] && mkdir -p "${HOME}/bin"
[ ! -d "${HOME}/.config/git" ] && mkdir -p "${HOME}/.config/git"

# for Git on Bash
if [ -x "$(which wget 2>/dev/null)" ]; then
    wget "${GIT_CONTRIB_URL}/git-completion.bash" --no-check-certificate -q -O "${HOME}/bin/git-completion.bash"
    wget "${GIT_CONTRIB_URL}/git-prompt.sh" --no-check-certificate -q -O "${HOME}/bin/git-prompt.sh"
elif [ -x "$(which curl 2>/dev/null)" ]; then
    curl "${GIT_CONTRIB_URL}/git-completion.bash" -L -s -o "${HOME}/bin/git-completion.bash"
    curl "${GIT_CONTRIB_URL}/git-prompt.sh" -L -s -o "${HOME}/bin/git-prompt.sh"
fi

for dotfile in .?*; do
    case "${dotfile}" in
    .. | .git | .gitmodules)
        # ignore
        continue
        ;;
    *)
        # symlink
        ln -sfni "${PWD}/${dotfile}" "${HOME}"
        ;;
    esac
done
