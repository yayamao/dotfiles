#!/bin/bash

# Echoes all commands before executing.
# set -o verbose
# set -x

# Exit on any errors
set -e

readonly SCRIPT_DIR=$(dirname $(realpath -s ${BASH_SOURCE[0]}))

function copy() {
  if [ ! -f $from ]; then
    echo "Can not find file: $from."
    exit 1
  fi

  local from=$1
  local to=$2
  if [ -f $to ]; then
    mkdir -p ${SCRIPT_DIR}/backup
    mv $to ${SCRIPT_DIR}/backup
  fi
  echo "Copy file from \"$from\" to \"$to\""
  ln -s $from $to
}

function install() {
  if [[ $EUID > 0 ]]; then
    SUDO="sudo -H"
  fi

  app=$1
  if [[ "$app" == "pip3" ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
    ${SUDO} python3 /tmp/get-pip.py
    rm /tmp/get-pip.py
    return 0
  fi

  echo "Installing $app"
  if [[ "$OSTYPE" == "linux"* ]]; then
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
    read -p "Press any key to continue if you installed the $app."
    return 1
  fi

  return 0
}

function install_powerline_fonts() {
  if [[ "$OSTYPE" == "linux"* ]]; then
    local font_dir="$HOME/.local/share/fonts/"
    if [ ! -f $font_dir/PowerlineSymbols.otf ]; then
      hash fc-cache 2> /dev/null ||  install fontconfig

      wget -q https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf -O /tmp/PowerlineSymbols.otf
      mkdir -p $font_dir && mv /tmp/PowerlineSymbols.otf $font_dir
      fc-cache -vf $font_dir

      local font_config_dir="$HOME/.config/fontconfig/conf.d/"
      wget -q https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf -O /tmp/10-powerline-symbols.conf
      mkdir -p $font_config_dir && mv /tmp/10-powerline-symbols.conf $font_config_dir
    fi
  fi

  # Install patched powerline fonts.
  git clone https://github.com/powerline/fonts.git /tmp/fonts
  cd /tmp/fonts
  bash ./install.sh
  cd -
  rm -rf /tmp/fonts
}

function install_monaco_font() {
  if [[ "$OSTYPE" == "linux"* ]]; then
    local font_dir="$HOME/.local/share/fonts/"
    if [ ! -f $font_dir/Monaco_Linux.ttf ]; then
      hash fc-cache 2> /dev/null ||  install fontconfig

      wget -q http://codybonney.com/files/fonts/Monaco_Linux.ttf -O /tmp/Monaco_Linux.ttf
      mkdir -p $font_dir && mv /tmp/Monaco_Linux.ttf $font_dir
      fc-cache -vf $font_dir
    fi
  fi
}

function init() {
  hash wget 2> /dev/null ||  install wget
  hash git 2> /dev/null ||  install git
  hash python3 2> /dev/null ||  install python3

  if [[ "$INSTALL_FONTS" == "true"  ]]; then
    install_monaco_font
  fi
}

function setup_powerline() {
  echo "Setting up powerline ..."

  hash pip3 2> /dev/null ||  install pip3
  pip3 install --user setuptools wheel
  pip3 install --user powerline-status

  if [[ "$INSTALL_FONTS" == "true"  ]]; then
    install_powerline_fonts
  fi
}

function setup_bash() {
  echo "Setting up bash configuration ..."

  # Setup Trash path.
  mkdir -p ~/.local/share/Trash/files

  mkdir -p $HOME/.bash/
  copy $SCRIPT_DIR/bash/.bash/bash_environment $HOME/.bash/bash_environment
  copy $SCRIPT_DIR/bash/.bash/bash_functions $HOME/.bash/bash_functions
  copy $SCRIPT_DIR/bash/.bash/bash_aliases $HOME/.bash/bash_aliases

  copy $SCRIPT_DIR/bash/.bash_profile $HOME/.bash_profile
  copy $SCRIPT_DIR/bash/.bashrc $HOME/.bashrc
  copy $SCRIPT_DIR/bash/.bash_logout $HOME/.bash_logout
}

function setup_screen() {
  echo "Setting up screen configuration ..."

  mkdir -p $HOME/.screen/
  copy $SCRIPT_DIR/screen/.screen/resource_stat.sh $HOME/.screen/resource_stat.sh

  copy $SCRIPT_DIR/screen/.screenrc $HOME/.screenrc
}

function setup_tmux() {
  echo "Setting up tmux configuration ..."

  hash tmux 2> /dev/null || install tmux

  copy $SCRIPT_DIR/tmux/.tmux.conf $HOME/.tmux.conf
}

function setup_vim() {
  echo "Setting up Vim configuration ..."

  [[ -d /usr/share/vim/vim81 ]] || install vim

  mkdir -p $HOME/.vim/

  copy $SCRIPT_DIR/vim/.vim/vimrc $HOME/.vim/vimrc
  if [[ "$INSTALL_FONTS" == "true"  ]]; then
    sed -i 's|^let g:airline_powerline_fonts = 0|let g:airline_powerline_fonts = 1|' $HOME/.vim/vimrc
  fi

  echo "Installing Vundle.Vim ..."
  if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git \
      $HOME/.vim/bundle/Vundle.vim
  fi

  if [[ "$INSTALL_VIM_PLUGINS" == "true"  ]]; then
    echo "Installing Vim plugins ..."
    vim +PluginInstall +qall
  fi
}

INSTALL_FONTS=${INSTALL_FONTS-false}
INSTALL_VIM_PLUGINS=${INSTALL_VIM_PLUGINS-false}

init
setup_powerline
setup_bash
setup_screen
setup_tmux
setup_vim
