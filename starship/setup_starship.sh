#!/bin/bash

echo -e "\nStarting Starship setup...\n"

# Install Starship
if ! command -v starship >/dev/null 2>&1; then
  echo -e "Starship not found, running curl..."
  curl -fsSL https://starship.rs/install.sh | bash
else
  echo -e "Starship is already installed. Skipping installation..."
fi

echo -e "\nStarship setup complete!\n"
