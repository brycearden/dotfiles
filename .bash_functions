#!/bin/bash
# vim: foldmethod=marker:foldlevel=0

# Miscellaneous {{{
function echoerr() {
	echo "$@" 1>&2
}

function colors() {
    for code in {0..255}; do
        echo -e "\e[38;05;${code}m $code: Test";
    done
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
    cd "$dir"
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