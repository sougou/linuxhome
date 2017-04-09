# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

function _init()
{
  _set_path
  _set_shortcuts
  _set_colors
  _set_options
  _set_prompt
  _set_git
  _set_vt
  _set_less
  _bash_completion
}

function _prepend_path()
{
  # $1 path variable
  # $2 path to add
  if [[ ":$1:" != *":$2:"* ]]; then
    echo "$2:$1"
  else
    echo "$1"
  fi
}

function _set_path()
{
  export PATH=$(_prepend_path $PATH /usr/local/go/bin)
}

function _set_shortcuts()
{
  alias scr="screen -dRA -S"
  alias mps="pgrep -fa"
  alias ..="cd .."
  alias ...="cd ../.."
  alias la="ls -a"
  alias ll="ls -la"
  alias l="ls -l"
}

function _set_colors()
{
  export CLICOLOR=1
  export LS_OPTIONS="-N --color -T 0"
  alias ls='/bin/ls ${LS_OPTIONS}'
}

function _set_options()
{
  umask 022  # rw-r--r--

  set -o noclobber
  set -o notify
  set -o vi
  export HISTCONTROL="erasedups:ignoreboth"
  export HISTFILESIZE=2000
  export HISTSIZE=2000
  shopt -s cmdhist
  shopt -s histappend
  shopt -s checkwinsize
  shopt -s execfail

  export EDITOR="/usr/bin/vi"
}

function _set_prompt()
{
  local PROMPT
  if [ -n "${ROOT_USER}" ]; then
    PROMPT='#'
  else
    PROMPT='>'
  fi

  FILTER_HOME="sed s/'\/home\/sougou'/~/"
  FILTER_VT="sed s/'dev\/src\/github\.com\/youtube\/'/.../"

  # Vanitization
  export SHORT_HOST=${HOSTNAME%%.*}

  if [ "${WINDOW}" ]; then
    PS1="\[\e[4m\]\$(pwd|${FILTER_HOME}|${FILTER_VT})${PROMPT}\[\e[m\] "
  else
    PS1="\[\e[4m\]${SHORT_HOST}: \$(pwd|${FILTER_HOME})${PROMPT}\[\e[m\] "
  fi
  export PS1
  export PROMPT_COMMAND=_set_screen_title
}

function _set_screen_title()
{
  if [ "${WINDOW}" ]; then
    screen -X title $(basename $(pwd))
  fi
}

function _set_git()
{
  if [ -f ~/util/git-completion.bash ]; then
    source ~/util/git-completion.bash
  fi
}

function _set_vt()
{
  export GOPATH=${HOME}/dev
  export MYSQL_FLAVOR=MySQL56
  export VT_MYSQL_ROOT=/usr
  pushd ${HOME}/dev/src/github.com/youtube/vitess > /dev/null
  source dev.env
  popd > /dev/null
}

# make less more friendly for non-text input files, see lesspipe(1)
function _set_less()
{
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
function _bash_completion()
{
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
     . /usr/share/bash-completion/bash_completion
   elif [ -f /etc/bash_completion ]; then
     . /etc/bash_completion
    fi
  fi
}

# _init calls everything else
_init
