#!/bin/bash

function copy() {
  local from=$1
  local to=$2
  if [ -f $to ]; then
    diff $from $to > /dev/null || vimdiff $from $to
  else
    echo "Copy file from \"$from\" to \"$to\""
    cp $from $to
  fi
}

function setup_bash() {
  [ -d ~/.bash ] || mkdir ~/.bash
  copy $PWD/bash/.bash/bash_environment $HOME/.bash/bash_environment
  copy $PWD/bash/.bash/bash_functions $HOME/.bash/bash_functions
  copy $PWD/bash/.bash/bash_aliases $HOME/.bash/bash_aliases

  copy $PWD/bash/.bash_profile $HOME/.bash_profile
  copy $PWD/bash/.bashrc $HOME/.bashrc
  copy $PWD/bash/.bash_logout $HOME/.bash_logout
}

setup_bash
