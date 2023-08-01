#!/bin/bash

echo -e "\nStarting tmux setup...\n"

# Change working directory to location of the script
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $DIR

# Symlink ssh config files
ln -f $DIR/.tmux.conf ~/.tmux.conf

echo -e "\nTmux setup complete!\n"