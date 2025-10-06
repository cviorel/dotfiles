#!/bin/bash

# Script to set up git-prompt on a fresh Ubuntu installation
# Creates an enhanced git-aware bash prompt

echo "Setting up git-prompt functionality..."

# Install prerequisites
echo "Installing required packages..."
sudo apt update
sudo apt install -y git bash-completion curl

# Create backup of existing .bashrc if it exists
if [ -f ~/.bashrc ]; then
  echo "Creating backup of existing .bashrc file..."
  cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d%H%M%S)
fi

# Find git-prompt.sh in common locations
GIT_PROMPT_LOCATIONS=(
  "/usr/lib/git-core/git-sh-prompt"
  "/usr/share/git-core/contrib/completion/git-prompt.sh"
  "/etc/bash_completion.d/git-prompt"
)

GIT_PROMPT_FOUND=false
GIT_PROMPT_PATH=""

for location in "${GIT_PROMPT_LOCATIONS[@]}"; do
  if [ -f "$location" ]; then
    GIT_PROMPT_FOUND=true
    GIT_PROMPT_PATH="$location"
    echo "Found git-prompt at: $location"
    break
  fi
done

# Download git-prompt.sh if not found
if [ "$GIT_PROMPT_FOUND" = false ]; then
  echo "Git prompt not found in system locations, downloading from GitHub..."
  mkdir -p ~/.git-prompt
  curl -s -o ~/.git-prompt/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
  GIT_PROMPT_PATH=~/.git-prompt/git-prompt.sh
  echo "Downloaded git-prompt to: $GIT_PROMPT_PATH"
fi

# Create git-prompt configuration to append to .bashrc
cat > ~/.git-prompt-config << 'EOF'

# Git prompt configuration
# -------------------------
# Source git-prompt script
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
  source /usr/lib/git-core/git-sh-prompt
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  source /usr/share/git-core/contrib/completion/git-prompt.sh
elif [ -f /etc/bash_completion.d/git-prompt ]; then
  source /etc/bash_completion.d/git-prompt
elif [ -f ~/.git-prompt/git-prompt.sh ]; then
  source ~/.git-prompt/git-prompt.sh
fi

# Configure git prompt options
export GIT_PS1_SHOWDIRTYSTATE=1      # Show * for unstaged and + for staged changes
export GIT_PS1_SHOWSTASHSTATE=1      # Show $ if stashes exist
export GIT_PS1_SHOWUNTRACKEDFILES=1  # Show % if there are untracked files
export GIT_PS1_SHOWUPSTREAM="auto"   # Show difference with upstream (< behind, > ahead, <> diverged)
export GIT_PS1_SHOWCOLORHINTS=1      # Show colored hints for status

# Define colors
COLOR_RESET="\[\033[0m\]"
COLOR_USER="\[\033[1;34m\]"  # Bold blue
COLOR_HOST="\[\033[0;36m\]"  # Cyan
COLOR_PATH="\[\033[0;32m\]"  # Green
COLOR_GIT="\[\033[0;91m\]"   # Red

# Set the prompt
PROMPT_COMMAND='__git_ps1 "${COLOR_USER}\u${COLOR_RESET}@${COLOR_HOST}\h${COLOR_RESET} ${COLOR_PATH}\w${COLOR_RESET}" " \$ "'

# For terminals that don't support PROMPT_COMMAND, fallback PS1
export PS1="${COLOR_USER}\u${COLOR_RESET}@${COLOR_HOST}\h${COLOR_RESET} ${COLOR_PATH}\w${COLOR_GIT}\$(__git_ps1 ' (%s)')${COLOR_RESET} \$ "
EOF

# Append the git-prompt configuration to .bashrc if not already there
if ! grep -q "Git prompt configuration" ~/.bashrc; then
  echo "Updating .bashrc with git-prompt configuration..."
  cat ~/.git-prompt-config >> ~/.bashrc
  echo "Git prompt configuration added to .bashrc"
else
  echo "Git prompt configuration already exists in .bashrc"
fi

# Create a test Git repository to verify setup
echo "Creating a test Git repository to verify setup..."
mkdir -p ~/git-prompt-test
cd ~/git-prompt-test
git init > /dev/null 2>&1
touch README.md
git add README.md > /dev/null 2>&1
git commit -m "Initial commit" > /dev/null 2>&1

echo
echo "Installation complete!"
echo "----------------------------------------------------------------------"
echo "To activate the new prompt, either:"
echo "  1. Start a new terminal session"
echo "  2. Run: source ~/.bashrc"
echo
echo "A test repository has been created at ~/git-prompt-test"
echo "You can test the git-prompt by navigating to this directory."
echo "----------------------------------------------------------------------"
echo "Enjoy your enhanced Git prompt!"
