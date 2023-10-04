#!/bin/bash

# -------------------------------------------------------------------
# extract - archive extractor
# usage: extract <file>
extract() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar x $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -------------------------------------------------------------------
# mkdir and then cd into it
mcd() {
    mkdir -p $1
    cd $1
}

# -------------------------------------------------------------------
decode_base64() {
    if [ ${#} -ne 2 ]; then
        echo "Usage: ${FUNCNAME[0]} <file>"
        return
    fi

    echo ${1} | base64 -d
}

# -------------------------------------------------------------------
rename_branch() {
    if [ ${#} -ne 2 ]; then
        echo "Usage: ${FUNCNAME[0]} <old-branch> <new-branch>"
        return
    fi

    git switch ${1}
    git branch -m ${2}      # renames the current branch to the new branch on local.
    git push origin :${1}   # deletes the old branch on remote.
    git push -u origin ${2} # creates the new branch on remote and resets the upstream branch to it.
}

# -------------------------------------------------------------------
# box: a function to create a box of '=' characters around a given string
#
# usage: box 'testing'
box() {
    local t="$1xxxx"
    local c=${2:-"#"}

    echo ${t//?/$c}
    echo "$c $1 $c"
    echo ${t//?/$c}
}

# -------------------------------------------------------------------
# netstat_used_local_ports: get used tcp-ports
netstat_used_local_ports() {
    netstat -atn |
        awk '{printf "%s\n", $4}' |
        grep -oE '[0-9]*$' |
        sort -n |
        uniq
}

# -------------------------------------------------------------------
# netstat_free_local_port: get one free tcp-port
netstat_free_local_port() {
    # didn't work with zsh / bash is ok
    # read lowerPort upperPort < /proc/sys/net/ipv4/ip_local_port_range

    for port in $(seq 32768 61000); do
        for i in $(netstat_used_local_ports); do
            if [[ $used_port -eq $port ]]; then
                continue
            else
                echo $port
                return 0
            fi
        done
    done

    return 1
}

# -------------------------------------------------------------------
# sniff: view HTTP traffic
#
# usage: sniff [eth0]
sniff() {
    if [ $1 ]; then
        local device=$1
    else
        local device='eth0'
    fi

    sudo ngrep -d ${device} -t '^(GET|POST) ' 'tcp and port 80'
}

# -------------------------------------------------------------------
# httpdump: view HTTP traffic
#
# usage: httpdump [eth1]
httpdump() {
    if [ $1 ]; then
        local device=$1
    else
        local device='eth0'
    fi

    sudo tcpdump -i ${device} -n -s 0 -w - | grep -a -o -E \"Host\: .* | GET \/.*\"
}

# -------------------------------------------------------------------
# givedef: shell function to define words
givedef() {
    if [ $# -ge 2 ]; then
        echo "givedef: too many arguments" >&2
        return 1
    else
        curl --silent "dict://dict.org/d:$1"
    fi
}

# -------------------------------------------------------------------
# rand_int: use "urandom" to get random int values
#
# usage: rand_int 8 --> e.g.: 32245321
rand_int() {
    if [ $1 ]; then
        local length=$1
    else
        local length=16
    fi

    tr -dc 0-9 </dev/urandom | head -c${1:-${length}}
}

# -------------------------------------------------------------------
# passwdgen: a password generator
#
# usage: passwdgen 8 --> e.g.: f4lwka_2f
passwdgen() {
    if [ $1 ]; then
        local length=$1
    else
        local length=16
    fi

    tr -dc A-Za-z0-9_ </dev/urandom | head -c${1:-${length}}
}

# -------------------------------------------------------------------
# gitio: create a git.io short URL
gitio() {
    if [ -z "${1}" ]; then
        echo "Usage: \`gitio github-url-or-shortcut\`"
        return 1
    fi

    local url
    local code

    if [[ "$1" =~ "https:" ]]; then
        url=$1
    else
        url="https://github.com/${1}"
    fi

    code=$(curl_post -k https://git.io/create -F "url=${url}")
    echo https://git.io/${code}
}

# -------------------------------------------------------------------
# pidenv: show PID environment in human-readable form
#
# https://github.com/darkk/home/blob/master/bin/pidenv
pidenv() {
    local multipid=false
    local pid=""

    if [ $# = 0 ]; then
        echo "Usage: $0: pid [pid] [pid]..."
        return 0
    fi

    if [ $# -gt 1 ]; then
        multipid=true
    fi

    while [ $# != 0 ]; do
        pid=$1
        shift

        if [ -d "/proc/$pid" ]; then
            if $multipid; then
                sed "s,\x00,\n,g" </proc/$pid/environ | sed "s,^,$pid:,"
            else
                sed "s,\x00,\n,g" </proc/$pid/environ
            fi
        else
            echo "$0: $pid is not a pid" 1>&2
        fi
    done
}
