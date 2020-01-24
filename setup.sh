#!/bin/bash

# Echoes all commands before executing.
# set -x

# Exit on any errors
set -e

function realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

readonly SCRIPT_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

echo SCRIPT_DIR: $SCRIPT_DIR

function create_directory() {
  dir=$1
  if [[ ! -d $dir ]]; then
    echo "Creating directory: $dir"
    mkdir -p $dir
  fi
}

function copy() {
  if [ ! -f $from ]; then
    echo "Can not find file: $from."
    exit 1
  fi

  local from=$1
  local to=$2
  if [ -f $to ]; then
    create_directory ${SCRIPT_DIR}/backup
    mv $to ${SCRIPT_DIR}/backup
  fi
  echo "Link file from \"$from\" to \"$to\""
  ln -s $from $to
}

function install() {
  app=$1
  echo "Installing app $app ..."

  if [[ "$app" == "pip3" ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
    python3 /tmp/get-pip.py --user
    rm /tmp/get-pip.py
    return 0
  fi

  if [[ "$OSTYPE" == "linux"* ]]; then
    if [[ $EUID > 0 ]]; then
      SUDO="sudo -H"
    fi
    if [[ "$app" == "vim" ]]; then
      ${SUDO} apt-get install -y --no-install-recommends software-properties-common
      ${SUDO} add-apt-repository ppa:jonathonf/vim
      ${SUDO} apt-get update
    fi
    ${SUDO} apt-get install -y --no-install-recommends $app
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install $app
  else
    echo "Please install $app ..."
    read -p "Press any key to continue if you have installed the $app."
    return 1
  fi

  return 0
}

function install_font() {
  font=$1
  font_name=$(basename $font)

  local font_dir=""
  if [[ "$OSTYPE" == "linux"* ]]; then
    font_dir="$HOME/.local/share/fonts"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    font_dir="$HOME/Library/Fonts"
    # Skip monaco.ttf for macOS as it is a native font.
    [[ $font_name == "monaco.ttf" ]] && return 0
  else
    echo "Please install font from $font ..."
    read -p "Press any key to continue if you have installed the font."
    return 1
  fi

  create_directory $font_dir
  if [[ ! -f $font_dir/$font_name ]]; then
    echo "Installing font $font ..."
    copy $font $font_dir/$font_name
    if [[ "$OSTYPE" == "linux"* ]]; then
      hash fc-cache 2> /dev/null || install fontconfig
      fc-cache -vf $font_dir
    fi
  fi

  return 0
}

function init() {
  echo "Initializing ..."

  hash wget 2> /dev/null || install wget
  hash git 2> /dev/null || install git
  hash python3 2> /dev/null || install python3
  if [[ "$INSTALL_FONTS" == "true" ]]; then
    install_font $SCRIPT_DIR/fonts/monaco.ttf
  fi
}

function setup_powerline() {
  echo "Setting up powerline ..."

  hash pip3 2> /dev/null || install pip3
  pip3 install --user setuptools wheel
  pip3 install --user powerline-status
  if [[ "$INSTALL_FONTS" == "true" ]]; then
    install_font $SCRIPT_DIR/fonts/monaco_for_powerline.ttf
  fi
}

function setup_bash() {
  echo "Setting up bash ..."

  # Setup Trash path wich will be used in ~/.bash/bash_aliases
  create_directory ~/.local/share/Trash/files

  create_directory $HOME/.bash/
  copy $SCRIPT_DIR/bash/.bash/bash_environment $HOME/.bash/bash_environment
  copy $SCRIPT_DIR/bash/.bash/bash_functions $HOME/.bash/bash_functions
  copy $SCRIPT_DIR/bash/.bash/bash_aliases $HOME/.bash/bash_aliases

  copy $SCRIPT_DIR/bash/.bash_profile $HOME/.bash_profile
  copy $SCRIPT_DIR/bash/.bashrc $HOME/.bashrc
  copy $SCRIPT_DIR/bash/.bash_logout $HOME/.bash_logout
}

function setup_screen() {
  echo "Setting up screen ..."

  create_directory $HOME/.screen/
  copy $SCRIPT_DIR/screen/.screen/resource_stat.sh $HOME/.screen/resource_stat.sh

  copy $SCRIPT_DIR/screen/.screenrc $HOME/.screenrc
}

function setup_tmux() {
  echo "Setting up tmux ..."

  hash tmux 2> /dev/null || install tmux

  copy $SCRIPT_DIR/tmux/.tmux.conf $HOME/.tmux.conf
}

function setup_vim() {
  echo "Setting up Vim ..."

  [[ ! -z `vim --version | head -1 | grep 8.2` ]] || install vim

  create_directory $HOME/.vim/

  if [[ "$INSTALL_FONTS" == "true" ]]; then
    sed -i.bak 's|^let g:airline_powerline_fonts = 0|let g:airline_powerline_fonts = 1|' $SCRIPT_DIR/vim/.vim/vimrc
    rm $SCRIPT_DIR/vim/.vim/vimrc.bak
  fi
  copy $SCRIPT_DIR/vim/.vim/vimrc $HOME/.vim/vimrc

  if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    echo "Installing Vundle.Vim ..."
    git clone https://github.com/VundleVim/Vundle.vim.git \
      $HOME/.vim/bundle/Vundle.vim
  fi

  if [[ "$INSTALL_VIM_PLUGINS" == "true" ]]; then
    echo "Installing Vim plugins ..."
    vim +PluginInstall +qall
  fi
}

INSTALL_FONTS=${INSTALL_FONTS-true}
INSTALL_VIM_PLUGINS=${INSTALL_VIM_PLUGINS-false}

init
setup_powerline
setup_bash
# setup_screen
setup_tmux
setup_vim
