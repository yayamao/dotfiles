#!/bin/bash

function copy() {
  local from=$1
  local to=$2
  echo "Copy file from \"$from\" to \"$to\""
  if [ -f $to ]; then
    vimdiff $from $to
  else
    cp $from $to
  fi
}

function setup_bash() {
  mkdir ~/.bash
  copy $PWD/bash/.bash/bash_environment $HOME/.bash/bash_environment
  copy $PWD/bash/.bash/bash_function $HOME/.bash/bash_function
  copy $PWD/bash/.bash/bash_aliases $HOME/.bash/bash_aliases

  copy $PWD/bash/.bash_profile $HOME/.bash_profile
  copy $PWD/bash/.bashrc $HOME/.bashrc
  copy $PWD/bash/.bash_logout $HOME/.bash_logout
}

setup_bash
