#!/bin/bash

set -e

# Change working directory to location of the script
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $DIR

# ensure there's a font directory
mkdir -p $HOME/.local/share/fonts

# Symlink fonts to local font folder
ln -sf $DIR/MesloLGS\ NF ~/.local/share/fonts/

# Update font cache
echo "Updating font cache..."
fc-cache -v