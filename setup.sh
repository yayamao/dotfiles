#!/bin/bash

# Echoes all commands before executing.
# set -o verbose

# Exit on any errors
set -e

function copy() {
  if [ ! -f $from ]; then
    echo "Can not find file: $from."
    exit 1
  fi

  local from=$1
  local to=$2
  if [ -f $to ]; then
    diff $from $to > /dev/null || vimdiff $from $to
  else
    echo "Copy file from \"$from\" to \"$to\""
    cp $from $to
  fi
}

function setup_powerline() {
  echo "Setting up powerline ..."

  if [[ "$OSTYPE" == "linux"* ]]; then
    sudo apt-get install python-pip git
    pip install --user powerline-status

    wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    mkdir -p ~/.fonts/ && mv PowerlineSymbols.otf ~/.fonts/
    fc-cache -vf ~/.fonts

    wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p ~/.fonts.conf.d/ && mv 10-powerline-symbols.conf ~/.fonts.conf.d/
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    sudo port select python python27-apple
    brew install python
    pip install --user powerline-status
  else
    echo "Please go to https://powerline.readthedocs.io/en/latest/installation.html# and install the powerline."
    read -p "Press any key to continue if you installed the powerline."
  fi

  # Install powerline fonts.
  git clone https://github.com/powerline/fonts.git /tmp/fonts
  cd /tmp/fonts
  sh ./install.sh
  cd -
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

  source $HOME/.bashrc
}

function setup_screen() {
  echo "Setting up screen configuration ..."

  mkdir -p $HOME/.screen/
  copy $PWD/screen/.screen/resource_stat.sh $HOME/.screen/resource_stat.sh

  copy $PWD/screen/.screenrc $HOME/.screenrc
}

function setup_tmux() {
  echo "Setting up tmux configuration ..."

  copy $PWD/tmux/.tmux.conf $HOME/.tmux.conf
}

function setup_vim() {
  echo "Setting up Vim configuration ..."

  mkdir -p $HOME/.vim/

  copy $PWD/vim/.vim/statusline.vim $HOME/.vim/statusline.vim
  copy $PWD/vim/.vim/vimrc $HOME/.vim/vimrc

  echo "Installing Vundle.Vim ..."
  if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git \
      $HOME/.vim/bundle/Vundle.vim
  fi

  echo "Installing Vim plugins ..."
  vim +PluginInstall +qall
}

setup_powerline
setup_bash
setup_screen
setup_tmux
setup_vim
