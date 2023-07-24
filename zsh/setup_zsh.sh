#!/bin/bash

echo -e "\nStarting zsh config setup...\n"

# Change working directory to location of the script
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $DIR

# Symlink zsh config files
ln -sf $DIR/.zshrc $HOME/.zshrc
ln -sf $DIR/.zshrc.pre-oh-my-zsh $HOME/.zshrc.pre-oh-my-zsh
ln -sf $DIR/.zshrc.zni $HOME/.zshrc.zni
ln -sf $DIR/.zprofile $HOME/.zprofile
ln -sf $DIR/.fzf.zsh $HOME/.fzf.zsh

echo -e "\nZsh config setup complete!\n"