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

function install() {
  if [[ "$OSTYPE" == "linux"* ]]; then
    sudo apt-get install $1
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install $1
  else
    echo "Please install $1 ..."
    read -p "Press any key to continue if you installed the $1."
  fi
}

function install_powerline() {
  echo "Setting up powerline ..."

  if [[ "$OSTYPE" == "linux"* ]]; then
    sudo apt-get install python-pip
    pip install --user powerline-status

    local font_dir="$HOME/.fonts/"
    wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    mkdir -p $font_dir && mv PowerlineSymbols.otf $font_dir
    fc-cache -vf $font_dir

    local font_config_dir="$HOME/.config/fontconfig/conf.d/";
    wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p $font_config_dir && mv 10-powerline-symbols.conf $font_config_dir
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    sudo easy_install pip
    pip install --user powerline-status
  else
    echo "Please go to https://powerline.readthedocs.io/en/latest/installation.html# and install the powerline."
    read -p "Press any key to continue if you installed the powerline."
  fi

  # Install powerline fonts.
  git clone https://github.com/powerline/fonts.git /tmp/fonts
  cd /tmp/fonts
  bash ./install.sh
  cd -
  rm -rf /tmp/fonts
}

function install_monaco_font() {
  local font_dir="/usr/share/fonts/truetype/ttf_monaco/"
  if [ ! -f $font_dir/Monaco_Linux.ttf ]; then
    echo "Setting up monaco font ..."
    sudo mkdir -p $font_dir
    wget http://codybonney.com/files/fonts/Monaco_Linux.ttf
    sudo mv Monaco_Linux.ttf $font_dir
    sudo fc-cache -vf $font_dir
  fi
}

function init() {
  hash git 2> /dev/null ||  install git
  hash tmux 2> /dev/null || install tmux
  hash vim 2> /dev/null || install vim

  hash powerline 2> /dev/null || install_powerline

  # Install monaco font for linux.
  [[ "$OSTYPE" == "linux"* ]] && install_monaco_font

  # Trash path.
  mkdir -p ~/.local/share/Trash/files
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

  bash $HOME/.bashrc
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

init
setup_bash
setup_screen
setup_tmux
setup_vim
