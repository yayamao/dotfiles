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
  echo "Setting up bash configuration ..."

  mkdir -p $HOME/.bash/
  copy $PWD/bash/.bash/bash_environment $HOME/.bash/bash_environment
  copy $PWD/bash/.bash/bash_functions $HOME/.bash/bash_functions
  copy $PWD/bash/.bash/bash_aliases $HOME/.bash/bash_aliases

  copy $PWD/bash/.bash_profile $HOME/.bash_profile
  copy $PWD/bash/.bashrc $HOME/.bashrc
  copy $PWD/bash/.bash_logout $HOME/.bash_logout
}

function setup_vim() {
  echo "Setting up Vim configuration ..."

  mkdir -p $HOME/.vim/

  copy $PWD/vim/.vim/vimrc $HOME/.vim/vimrc
  copy $PWD/vim/.vim/statusline.vim $HOME/.vim/statusline.vim

  echo "Installing Vundle.Vim ..."
  if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  fi

  echo "Installing Vim plugins ..."
  vim +PluginInstall +qall
}

setup_bash
setup_vim
