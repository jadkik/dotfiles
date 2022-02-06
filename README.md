# dotfiles

X

## zsh setup:

```
mkdir ~/.zpresto-contrib
git clone https://github.com/mroth/evalcache.git ~/.zpresto-contrib/evalcache
git clone https://github.com/prezto-contributions/prezto-kubectl.git ~/.zpresto-contrib/prezto-kubectl
```

Apply this patch to zpresto:

```patch
diff --git a/modules/python/init.zsh b/modules/python/init.zsh
index 91aa6d0..bb78748 100644
--- a/modules/python/init.zsh
+++ b/modules/python/init.zsh
@@ -20,12 +20,12 @@ if [[ -s "${local_pyenv::=${PYENV_ROOT:-$HOME/.pyenv}/bin/pyenv}" ]] \
   [[ -s $local_pyenv ]] && path=($local_pyenv:h $path)

   # pyenv 2+ requires shims to be added to path before being initialized.
-  autoload -Uz is-at-least
-  if is-at-least 2 ${"$(pyenv --version 2>&1)"[(w)2]}; then
+#  autoload -Uz is-at-least
+#  if is-at-least 2 ${"$(pyenv --version 2>&1)"[(w)2]}; then
     eval "$(pyenv init --path zsh)"
-  fi
+#  fi

-  eval "$(pyenv init - zsh)"
+  eval "$(pyenv init --no-rehash - zsh)"

 # Prepend PEP 370 per user site packages directory, which defaults to
 # ~/Library/Python on macOS and ~/.local elsewhere, to PATH. The
@@ -48,46 +48,46 @@ if (( ! $#commands[(i)python[23]#] && ! $+functions[pyenv] && ! $+commands[conda
   return 1
 fi

-function _python-workon-cwd {
-  # Check if this is a Git repo.
-  local GIT_REPO_ROOT="$(git rev-parse --show-toplevel 2> /dev/null)"
-  # Get absolute path, resolving symlinks.
-  local PROJECT_ROOT="$PWD:A"
-  while [[ "$PROJECT_ROOT" != "/" && ! -e "$PROJECT_ROOT/.venv" \
-        && ! -d "$PROJECT_ROOT/.git"  && "$PROJECT_ROOT" != "$GIT_REPO_ROOT" ]]; do
-    PROJECT_ROOT="$PROJECT_ROOT:h"
-  done
-  if [[ $PROJECT_ROOT == "/" ]]; then
-    PROJECT_ROOT="."
-  fi
-  # Check for virtualenv name override.
-  local ENV_NAME=""
-  if [[ -f "$PROJECT_ROOT/.venv" ]]; then
-    ENV_NAME="$(<$PROJECT_ROOT/.venv)"
-  elif [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]]; then
-    ENV_NAME="$PROJECT_ROOT/.venv"
-  elif [[ $PROJECT_ROOT != "." ]]; then
-    ENV_NAME="$PROJECT_ROOT:t"
-  fi
-  if [[ -n $CD_VIRTUAL_ENV && "$ENV_NAME" != "$CD_VIRTUAL_ENV" ]]; then
-    # We've just left the repo, deactivate the environment.
-    # Note: this only happens if the virtualenv was activated automatically.
-    deactivate && unset CD_VIRTUAL_ENV
-  fi
-  if [[ $ENV_NAME != "" ]]; then
-    # Activate the environment only if it is not already active.
-    if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
-      if [[ -n "$WORKON_HOME" && -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
-        workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
-      elif [[ -e "$ENV_NAME/bin/activate" ]]; then
-        source $ENV_NAME/bin/activate && export CD_VIRTUAL_ENV="$ENV_NAME"
+# Load auto workon cwd hook.
+if zstyle -t ':prezto:module:python:virtualenv' auto-switch; then
+  function _python-workon-cwd {
+    # Check if this is a Git repo.
+    local GIT_REPO_ROOT="$(git rev-parse --show-toplevel 2> /dev/null)"
+    # Get absolute path, resolving symlinks.
+    local PROJECT_ROOT="$PWD:A"
+    while [[ "$PROJECT_ROOT" != "/" && ! -e "$PROJECT_ROOT/.venv" \
+          && ! -d "$PROJECT_ROOT/.git"  && "$PROJECT_ROOT" != "$GIT_REPO_ROOT" ]]; do
+      PROJECT_ROOT="$PROJECT_ROOT:h"
+    done
+    if [[ $PROJECT_ROOT == "/" ]]; then
+      PROJECT_ROOT="."
+    fi
+    # Check for virtualenv name override.
+    local ENV_NAME=""
+    if [[ -f "$PROJECT_ROOT/.venv" ]]; then
+      ENV_NAME="$(<$PROJECT_ROOT/.venv)"
+    elif [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]]; then
+      ENV_NAME="$PROJECT_ROOT/.venv"
+    elif [[ $PROJECT_ROOT != "." ]]; then
+      ENV_NAME="$PROJECT_ROOT:t"
+    fi
+    if [[ -n $CD_VIRTUAL_ENV && "$ENV_NAME" != "$CD_VIRTUAL_ENV" ]]; then
+      # We've just left the repo, deactivate the environment.
+      # Note: this only happens if the virtualenv was activated automatically.
+      deactivate && unset CD_VIRTUAL_ENV
+    fi
+    if [[ $ENV_NAME != "" ]]; then
+      # Activate the environment only if it is not already active.
+      if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
+        if [[ -n "$WORKON_HOME" && -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
+          workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
+        elif [[ -e "$ENV_NAME/bin/activate" ]]; then
+          source $ENV_NAME/bin/activate && export CD_VIRTUAL_ENV="$ENV_NAME"
+        fi
       fi
     fi
-  fi
-}
+  }

-# Load auto workon cwd hook.
-if zstyle -t ':prezto:module:python:virtualenv' auto-switch; then
   # Auto workon when changing directory.
   autoload -Uz add-zsh-hook
   add-zsh-hook chpwd _python-workon-cwd
diff --git a/runcoms/zpreztorc b/runcoms/zpreztorc
index cc6ebb4..21377e0 100644
--- a/runcoms/zpreztorc
+++ b/runcoms/zpreztorc
@@ -16,7 +16,7 @@
 zstyle ':prezto:*:*' color 'yes'

 # Add additional directories to load prezto modules from
-# zstyle ':prezto:load' pmodule-dirs $HOME/.zprezto-contrib
+zstyle ':prezto:load' pmodule-dirs $HOME/.zprezto-contrib

 # Allow module overrides when pmodule-dirs causes module name collisions
 # zstyle ':prezto:load' pmodule-allow-overrides 'yes'
@@ -29,17 +29,50 @@ zstyle ':prezto:*:*' color 'yes'

 # Set the Prezto modules to load (browse modules).
 # The order matters.
-zstyle ':prezto:load' pmodule \
-  'environment' \
-  'terminal' \
-  'editor' \
-  'history' \
-  'directory' \
-  'spectrum' \
-  'utility' \
-  'completion' \
-  'history-substring-search' \
+MY_MODULES=(
+  'environment'
+  'terminal'
+  'editor'
+  'history'
+  'directory'
+  'spectrum'
+  'utility'
+
+
+# Slow - but still faster than "vanilla" pyenv
+  'python'
+
+  'completion'
+  'syntax-highlighting'
+  'history-substring-search'
   'prompt'
+  'git'
+
+# Maybe has useful aliases?
+#  'kubectl'
+
+# Speed up nvm, jenv etc. (in tandem with .zutils.zsh)
+  'evalcache'
+
+# Not really useful
+#  'osx'
+#  'homebrew'
+#  'archive'
+
+# Needs some more config
+#  'tmux'
+
+# Needs a patched rsync (from homebrew?)
+#  'rsync'
+
+# Very slow
+#  'node'
+
+# Not installed
+#  'helm'
+
+)
+zstyle ':prezto:load' pmodule "${MY_MODULES[@]}";

 #
 # Autosuggestions
@@ -117,7 +150,7 @@ zstyle ':prezto:module:editor' key-bindings 'emacs'
 # Set the prompt theme to load.
 # Setting it to 'random' loads a random theme.
 # Auto set to 'off' on dumb terminals.
-zstyle ':prezto:module:prompt' theme 'sorin'
+zstyle ':prezto:module:prompt' theme 'agnoster'

 # Set the working directory prompt display length.
 # By default, it is set to 'short'. Set it to 'long' (without '~' expansion)
@@ -133,10 +166,13 @@ zstyle ':prezto:module:prompt' theme 'sorin'
 #

 # Auto switch the Python virtualenv on directory change.
-# zstyle ':prezto:module:python:virtualenv' auto-switch 'yes'
+zstyle ':prezto:module:python:virtualenv' auto-switch 'no'
+
+# Automatically initialize virtualenvwrapper if pre-requisites are met.
+zstyle ':prezto:module:python:virtualenv' initialize 'yes'

 # Automatically initialize virtualenvwrapper if pre-requisites are met.
-# zstyle ':prezto:module:python:virtualenv' initialize 'yes'
+zstyle ':prezto:module:python' skip-virtualenvwrapper-init 'on'

 #
 # Ruby
diff --git a/runcoms/zprofile b/runcoms/zprofile
index 1cf48bf..4dc4656 100644
--- a/runcoms/zprofile
+++ b/runcoms/zprofile
@@ -44,9 +44,14 @@ typeset -gU cdpath fpath mailpath path
 # Set the list of directories that Zsh searches for programs.
 path=(
   /usr/local/{bin,sbin}
+  "$HOME/.poetry-home/bin"
   $path
 )

+export POETRY_HOME="$HOME/.poetry-home"
+
+eval "$(pyenv init --path)"
+
 #
 # Less
 #
@@ -54,7 +59,7 @@ path=(
 # Set the default Less options.
 # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
 # Remove -X to enable it.
-export LESS='-g -i -M -R -S -w -X -z-4'
+export LESS='-g -i -M -R -S -w -X -z-4 -F'

 # Set the Less input preprocessor.
 # Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
```
