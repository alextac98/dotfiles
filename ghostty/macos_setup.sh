#!/usr/bin/bash

ghostty_config="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

rm -f "$ghostty_config"

ln -s "$CONFIG_HOME/ghostty/config" "$ghostty_config"