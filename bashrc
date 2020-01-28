# .bashrc

# powerline
if [ -f `which powerline-daemon` ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  . /usr/share/powerline/bash/powerline.sh
fi

# PATH changes
export PATH=~/tools:"$PATH"

# Custom functions and aliases
function findinfiles() {
    SEARCH=$1
    shift 1
    grep -nHIrF --color=ALWAYS $* -- "${SEARCH}" | less -R -S
}

function regexpinfiles() {
    SEARCH=$1
    shift 1
    grep -nHIrP --color=ALWAYS $* -- "${SEARCH}" | less -R -S
}

function nn {
    A="$1"
    AFILENAME=$(echo "$A" | cut -d':' -f 1)
    ALINENO=$(echo "$A" | cut -d':' -f 2)
    nano "+${ALINENO}" "$AFILENAME"
}

function viewjson {
    FILENAME="${1:--}"
    JQ_EXPRESSION="${2:-.}"
    shift 2
    JQ_ARGS="$*"
    cat "${FILENAME}" | jq $JQ_ARGS -C "${JQ_EXPRESSION}" | less -RS
}

alias ttysysall="ttysys 'vhm      s'"
alias git-ls-todos='git grep -l TODO | xargs -n1 git blame -f | grep TODO  | sed "s/\(.\+\)\s\+\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} +[0-9]\{4\}\)\s\+/\2 \1 /" | sort -hr | grep --color=ALWAYS TODO | less -SR'

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# direnv
eval "$(direnv hook bash)"
