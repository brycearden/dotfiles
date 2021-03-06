#!/usr/bin/env bash
# vim: foldmethod=marker:foldlevel=0

# Miscellaneous {{{
function echoerr() {
	echo "$@" 1>&2
}

function error_return() {
    echo "$1" 1>&2
    return 1
}

function colors() {
    for code in {0..255}; do
        echo -e "\e[38;05;${code}m $code: Test";
    done
}

# Create a new directory and enter it
function md() {
    mkdir -p "$@" && cd "$@"
}

function hist() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# find shorthand
function f() {
    find . -name "$1"
}

# set the background color to light
function light() {
    export BACKGROUND="light" && reload!
}

function dark() {
    export BACKGROUND="dark" && reload!
}

function confirm() {
    read -p "$1" -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
}

# get gzipped size
function gz() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# take this repo and copy it to somewhere else minus the .git stuff.
function gitexport(){
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
}

function exiterr() {
    # Exits with $1 error message and $2 error code
    echoerr -e "$(color 196)ERROR$RESET: $1"
    exit $2
}

function welcome_msg() {
    clear
    tput setaf 1 # Set terminal to output red
    if hash figlet 2>/dev/null; then
        figlet "Welcome, " $USER
    else
        echo "Welcome, " $USER
    fi
    tput sgr0 # Set terminal to normal
    COLUMNS=$(tput cols)
    echo -e ""
    echo -ne "Today is "; date
    echo -e ""; cal ;
    echo -ne "Up time:";uptime | awk /'up/'
    echo ""
}
# }}}

# Zipped Files {{{
function extract () {
    if [ -z "$1" ]; then
        # display usage if no parameters are given
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    else
        if [ -f $1 ]; then
            case $1 in
                *.tar.bz2)   tar xvjf $1     ;;
                *.tar.gz)    tar xvzf $1     ;;
                *.tar.xz)    tar xvJf $1     ;;
                *.lzma)      unlzma $1       ;;
                *.bz2)       bunzip2 $1      ;;
                *.rar)       unrar x -ad $1  ;;
                *.gz)        gunzip $1       ;;
                *.tar)       tar xvf $1      ;;
                *.tbz2)      tar xvjf $1     ;;
                *.tgz)       tar xvzf $1     ;;
                *.zip)       unzip $1        ;;
                *.Z)         uncompress $1   ;;
                *.7z)        7z x $1         ;;
                *.xz)        unxz $1         ;;
                *.exe)       cabextract $1   ;;
                *) echo "extract: '$1' - unknown archive method" ;;
            esac
        else
            echo "$1 -file does not exist"
        fi
    fi
}

function roll() {
    local file=$1
    case $file in
        *.tar.bz2) shift && tar cjf $file $* ;;
        *.tar.gz) shift && tar czf $file $* ;;
        *.tgz) shift && tar czf $file $* ;;
        *.zip) shift && zip $file $* ;;
        *.rar) shift && rar $file $* ;;
        *) echo "'$1' is not a valid archive type"
    esac
}
# }}}

# Navigation {{{
function up() {
    dir=""
    if [ -z "$1" ]; then
        dir=..
    elif [[ $1 =~ ^[0-9]+$ ]]; then
        x=0
        while [ $x -lt ${1:-1} ]; do
            dir=${dir}../
            x=$(($x+1))
        done
    else
        dir=${PWD%/$1/*}/$1
    fi
    cd "$dir" 2&> /dev/null || error_return "No such parent directory: $1"
}

function upstr() {
    local dir
    dir=$(up "$1" && pwd)
    if [[ $? > 0 ]]; then
        return 1
    fi
    echo "$dir"
}
# }}}

function khan_lint() {
	LINTDIR=~/khan/devtools/khan-linter; git diff -z --name-only --diff-filter=ACMRTUB '@{u}' | xargs -0 $LINTDIR/runlint.py --blacklist=yes
}

function git_loglive() {
    while :
    do
        clear
        git --no-pager log --graph --pretty=oneline --abbrev-commit --decorate --all $*
        sleep 1
    done
}


function file_open() {
    # Opens a file using xdg-open
    echo "Opening $1 ..."
    xdg-open "$1" > /dev/null 2>&1
}

# do sudo, or sudo last command if no argument given
function s() {
    if [[ $# == 0 ]]; then
        sudo $(history -p '!!')
    else
        sudo "$@"
    fi
}

function mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# TODO: figure out how to get the prompt to change color when in vi mode for bash
# # urxvt (and family) accepts even #RRGGBB
# INSERT_PROMPT="gray"
# COMMAND_PROMPT="red"

# # helper for setting color including all kinds of terminals
# set_prompt_color() {
#     if [[ $TERM = "linux" ]]; then
#        # nothing
#     elif [[ $TMUX != '' ]]; then
#         printf '\033Ptmux;\033\033]12;%b\007\033\\' "$1"
#     else
#         echo -ne "\033]12;$1\007"
#     fi
# }

# # change cursor color basing on vi mode
# zle-keymap-select () {
#     if [ $KEYMAP = vicmd ]; then
#         set_prompt_color $COMMAND_PROMPT
#     else
#         set_prompt_color $INSERT_PROMPT
#     fi
# }

# zle-line-finish() {
#     set_prompt_color $INSERT_PROMPT
# }

# zle-line-init () {
#     zle -K viins
#     set_prompt_color $INSERT_PROMPT
# }

# zle -N zle-keymap-select
# zle -N zle-line-init
# zle -N zle-line-finish

