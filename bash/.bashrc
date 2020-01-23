# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Load bash environment.
if [ -f ~/.bash/bash_environment ]; then
  . ~/.bash/bash_environment
fi

# Load some useful bash functions.
if [ -f ~/.bash/bash_functions ]; then
  . ~/.bash/bash_functions
fi

# Load some useful alias definitions.
if [ -f ~/.bash/bash_aliases ]; then
  . ~/.bash/bash_aliases
fi

# Load personal specifics.
if [ -f ~/.bash/bash_personal ]; then
  . ~/.bash/bash_personal
fi

