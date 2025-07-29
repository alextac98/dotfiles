#!/bin/bash

echo -e "\nWelcome to Alex's Dotfiles!\n"

MAINDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Make sure all submodules are updated
cd $MAINDIR
git submodule update --init --recursive

# Set up Starship
cd $MAINDIR
. ./starship/setup_starship.sh

# Set Up Tmux
cd $MAINDIR
. ./tmux/setup_tmux.sh

# Set up Vim
cd $MAINDIR
. ./vim/setup_vim.sh

# Set up Zsh
cd $MAINDIR
. ./zsh/setup_zsh.sh
source $HOME/.zshrc

echo -e "\nDotfile setup complete!\n"
