# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.dotfiles/zsh/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.dotfiles/zsh/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.dotfiles/zsh/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$HOME/.dotfiles/zsh/fzf/shell/key-bindings.zsh"
