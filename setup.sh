#!/bin/bash

# Echoes all commands before executing.
# set -o verbose

# Exit on any errors
set -e

SUDO="sudo"

function copy() {
  if [ ! -f $from ]; then
    echo "Can not find file: $from."
    exit 1
  fi

  local from=$1
  local to=$2
  if [ -f $to ]; then
    mkdir -p backup
    mv $to backup
  fi
  echo "Copy file from \"$from\" to \"$to\""
  ln -s $from $to
}

function install() {
  app=$1
  echo "Installing $app"
  if [[ "$OSTYPE" == "linux"* ]]; then
    if [[ "$app" == "pip3" ]]; then
      app=python3-pip
    fi
    if [[ "$app" == "vim" ]]; then
      ${SUDO} apt install -y --no-install-recommends software-properties-common
      ${SUDO} add-apt-repository ppa:jonathonf/vim
    fi
    ${SUDO} apt install -y --no-install-recommends $app
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ "$app" == "pip3" ]]; then
      app=python3
    fi
    brew install $app
  else
    echo "Please install $app ..."
    read -p "Press any key to continue if you installed the $app."
  fi
}

function install_powerline() {
  hash pip3 2> /dev/null ||  install pip3
  if [[ "$OSTYPE" == "linux"* ]]; then
    pip3 install --user setuptools wheel
    pip3 install --user powerline-status

    hash fc-cache 2> /dev/null ||  install fontconfig

    local font_dir="$HOME/.fonts/"
    wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    mkdir -p $font_dir && mv PowerlineSymbols.otf $font_dir
    fc-cache -vf $font_dir

    local font_config_dir="$HOME/.config/fontconfig/conf.d/";
    wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p $font_config_dir && mv 10-powerline-symbols.conf $font_config_dir
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    pip3 install --user setuptools wheel
    pip3 install --user powerline-status
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

    hash fc-cache 2> /dev/null ||  install fontconfig

    ${SUDO} mkdir -p $font_dir
    wget http://codybonney.com/files/fonts/Monaco_Linux.ttf
    ${SUDO} mv Monaco_Linux.ttf $font_dir
    ${SUDO} fc-cache -vf $font_dir
  fi
}

function init() {
  ${SUDO} apt update

  hash wget 2> /dev/null ||  install wget
  hash git 2> /dev/null ||  install git
}

function setup_fonts() {
  echo "Setting up fonts ..."

  # Install monaco font for linux.
  [[ "$OSTYPE" == "linux"* ]] && install_monaco_font
}

function setup_powerline() {
  echo "Setting up powerline ..."

  hash powerline 2> /dev/null || install_powerline
}

function setup_bash() {
  echo "Setting up bash configuration ..."

  # Setup Trash path.
  mkdir -p ~/.local/share/Trash/files

  mkdir -p $HOME/.bash/
  copy $PWD/bash/.bash/bash_environment $HOME/.bash/bash_environment
  copy $PWD/bash/.bash/bash_functions $HOME/.bash/bash_functions
  copy $PWD/bash/.bash/bash_aliases $HOME/.bash/bash_aliases

  copy $PWD/bash/.bash_profile $HOME/.bash_profile
  copy $PWD/bash/.bashrc $HOME/.bashrc
  copy $PWD/bash/.bash_logout $HOME/.bash_logout

  # Reload .bashrc
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

  hash tmux 2> /dev/null || install tmux

  copy $PWD/tmux/.tmux.conf $HOME/.tmux.conf
}

function setup_vim() {
  echo "Setting up Vim configuration ..."

  hash vim 2> /dev/null || install vim

  mkdir -p $HOME/.vim/

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
setup_fonts
setup_powerline
setup_bash
setup_screen
setup_tmux
setup_vim
