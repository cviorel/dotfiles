alias :q="echo \"This is not vim. You're tired, go to bed.\""
alias :wq=':q'
alias ls='ls --color=auto -F'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'   # colourized grep
alias egrep='egrep --color=auto' # colourized egrep
alias diff='colordiff'
alias crontab='crontab -i'

# Update system
alias update_system='sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove'

# Docker
alias d='docker'
alias dnone='docker rmi $(docker images -f "dangling=true" -q)'
alias dstop='docker stop $(docker ps -a -q)'
alias drm='docker rm $(docker ps -a -q)'
alias dclist='docker ps -a'
alias dilist='docker images'

# Kill all running containers.
alias dockerkillall='docker kill $(docker ps -q)'

# Delete all stopped containers
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'

# Delete all untagged images
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'

# Delete all stopped containers and untagged images
alias dockerclean='dockercleanc || true && dockercleani'
