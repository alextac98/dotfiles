# Set up XDG Config
export CONFIG_HOME="$HOME/.dotfiles"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set custom ZSH config directory
ZSH_CUSTOM=$CONFIG_HOME/zsh/configs

plugins=(
    git
    zsh-autosuggestions
)

# Source aliases
source "$CONFIG_HOME/zsh/.aliases"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Configure Shell with Starship
export STARSHIP_CONFIG="$CONFIG_HOME/starship/starship.toml"
eval "$(starship init zsh)"
