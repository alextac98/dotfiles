#!/bin/bash

echo -e "\nWelcome to Alex's Dotfiles!\n"

# Make sure all submodules are updated
git submodule update --init --recursive

# Set up Starship
. ./starship/setup_starship.sh

# Set Up Tmux
. ./tmux/setup_tmux.sh

# Set up Vim
. ./vim/setup_vim.sh

# Set up Zsh
. ./zsh/setup_zsh.sh
source $HOME/.zshrc

echo -e "\nDotfile setup complete!\n"
