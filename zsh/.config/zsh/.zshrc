# Powerful but minimal zsh configuration
#Author: Radley E. Sidwell-Lewis
# GitHub: https://www.github.com/radleylewis/zsh
#
# Uses:
#   Plugins:      fast-syntax-highlighting, zsh-autosuggestions,
#                 zsh-history-substring-search, zsh-vi-mode
#   Prompt:       starship
#   Navigation:   zoxide, fzf, fd
#   CLI tools:    eza, bat, nvim, ripgrep
#   Node:         nvm

# =========================================================
# History
# =========================================================

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1

# =========================================================
# Completion
# =========================================================

# Before anything that calls compdef (aliases.zsh) or adds completions (fzf's **<Tab>)

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# =========================================================
# Modular Config Files
# =========================================================

# fzf: defines its widgets and binds its own keys in the emacs, viins and vicmd keymaps
source "$ZDOTDIR/fzf.zsh"

# Aliases, then the shell functions (cr, lf)
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/functions.zsh"

# Plugins: after the custom widgets above, so syntax highlighting can wrap them
source "$ZDOTDIR/plugins.zsh"

# Vi mode and keybindings: after the plugins, so every widget exists when it is bound
source "$ZDOTDIR/keys.zsh"

# =========================================================
# Smart directory navigation
# =========================================================

# zoxide's docs say to initialise it after compinit, near the end
eval "$(zoxide init zsh)"

# =========================================================
# Prompt
# =========================================================

# Prevent Python virtualenv from polluting the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# After keys.zsh: starship wraps its zle-keymap-select hook to show ❮ in normal mode
eval "$(starship init zsh)"

# =========================================================
# SSH key
# =========================================================

# Put the key in the agent once per boot, so the first terminal asks for the passphrase.
# AddKeysToAgent in ~/.ssh/config only adds it when ssh connects somewhere, but git
# commit signing (ssh-keygen -Y sign) needs it in the agent beforehand.
# ssh-add -l exits 0 if the agent has keys, 1 if it has none, 2 if there's no agent.
ssh-add -l >/dev/null 2>&1
if [[ $? -eq 1 ]]; then
  ssh-add ~/.ssh/id_ed25519
fi

# =========================================================
# User Custom Configurations
# =========================================================

# Last, so machine-only overrides (gitignored) win over everything above
if [[ -f "$ZDOTDIR/local.zsh" ]]; then
  source "$ZDOTDIR/local.zsh"
fi
