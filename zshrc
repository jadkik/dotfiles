export LOG_ZSH_LOAD_TIME=true
#export LOG_ZSH_LOAD_TIME=
source "${ZDOTDIR:-$HOME}/.zutils.zsh"

# export PYENV_DEBUG=1

load_zprof
load_prezto
load_everything

export PYENV_VIRTUALENV_DISABLE_PROMPT=1
