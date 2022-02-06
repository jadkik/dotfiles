# See https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load.html
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

if [ -z "$LOG_ZSH_LOAD_TIME" ] ; then
  alias timemeasure=""
else
  timemeasure() {
    echo ">>> $1"
    before=$(gdate +%s%3N)
    "$@"
    after=$(gdate +%s%3N)
    echo "<<< $(( after - before ))ms"
  }
fi

# Custom load functions
load_direnv() {
  _evalcache direnv hook zsh
}

load_jenv_lazy() {
  export PATH="$HOME/.jenv/bin:$PATH"
}

load_jenv() {
  # jenv in the PATH is usually good enough
   _evalcache jenv init -
}

load_pyenv_lazy() {
  # Useful for the prezto python module
  # Alternative using direnv: https://github.com/direnv/direnv/wiki/Python
#  export PYENV_ROOT="$HOME/.pyenv"
#  export PATH="$PYENV_ROOT/bin:$PATH"
}

pyenv_wrapper_init() {
  pyenv init -
  pyenv virtualenv-init -
}

load_pyenv() {
#  if command -v pyenv 1>/dev/null 2>&1; then
  set -x
#  _evalcache pyenv init -
#  _evalcache pyenv virtualenv-init -
  _evalcache pyenv_wrapper_init
  set +x
#  fi
}

load_nvm_lazy() {
  # For nvm
  # Another alternative: https://github.com/lukechilds/zsh-nvm
  export NVM_PATH="/usr/local/opt/nvm/"
  export NVM_DIR="$HOME/.nvm"

  # For direnv's "use node" directive
  # See also https://github.com/direnv/direnv/wiki/Node
  export NODE_VERSIONS=~/.nvm/versions/node
  export NODE_VERSION_PREFIX=v
}

load_nvm() {
  [ -s "$NVM_PATH/nvm.sh" ] && . "$NVM_PATH/nvm.sh"
  [ -s "$NVM_PATH/etc/bash_completion.d/nvm" ] && . "$NVM_PATH/etc/bash_completion.d/nvm"
}

load_krew() {
  export PATH="${PATH}:${HOME}/.krew/bin"
}

load_mysql_client() {
  export PATH="/usr/local/opt/mysql-client/bin:$PATH"
}

load_custom_bin() {
  export PATH="$HOME/bin:$PATH"
}

load_zprof() {
  zmodload zsh/zprof
}

load_prezto() {
  # Source Prezto.
  if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
  fi
}

load_everything() {
  # Install statusline? https://github.com/el1t/statusline
  RPROMPT="[%D{%f/%m/%y} | %D{%L:%M:%S}]"

  load_direnv

  load_jenv_lazy
  #load_pyenv_lazy
  load_nvm_lazy

  #load_jenv
  # No need for this if you have the zpresto python module
  #load_pyenv
  #load_nvm

  #load_poetry
  load_krew
  load_mysql_client
  load_custom_bin

  source "${ZDOTDIR:-$HOME}/.zaliases.zsh"
}
