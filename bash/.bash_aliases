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
alias dockerkillall='docker ps -q | xargs -r docker kill'

# Delete all stopped containers
alias dockercleanc='echo -e "\n[INFO] Deleting stopped containers\n" && docker ps -f status=exited -q | xargs -r docker rm'

# Delete all untagged images
alias dockercleani='printf "\n[INFO] Deleting untagged images\n" && docker images -q -f dangling=true | xargs -r docker rmi'

# Delete all stopped containers and untagged images
alias dockerclean='dockercleanc || true && dockercleani'
