# ~/.config/zsh/.zshrc: options, completion, plugins, keys and prompt for interactive shells.
# zsh reads it after .zshenv in every interactive shell, login or not; scripts never read it.
# The whole setup (load order, file map, key bindings) is explained in ~/dotfiles/zsh/README.md.

# =========================================================
# History
# =========================================================

# In the XDG state folder instead of a dotfile in ~
HISTFILE="$XDG_STATE_HOME/zsh/history"

# Lines kept in memory and on disk; big enough that old commands stay searchable
HISTSIZE=100000
SAVEHIST=100000

# One history shared by every open terminal, without the noise
setopt APPEND_HISTORY
setopt SHARE_HISTORY           # each command is visible in the other terminals right away
setopt HIST_IGNORE_DUPS        # don't store a command twice in a row
setopt HIST_IGNORE_SPACE       # a leading space keeps a command out of history
setopt HIST_EXPIRE_DUPS_FIRST  # when trimming, drop duplicates before unique commands
setopt HIST_FIND_NO_DUPS       # searches don't show the same command twice

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD             # type a directory's name to cd into it
setopt NOBEEP             # no terminal bell on errors or failed completion
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1

# =========================================================
# Completion
# =========================================================

# Before anything that calls compdef (aliases.zsh) or adds completions (fzf's **<Tab>).
# The dump caches what compinit finds, so later shells start faster; it lives in the XDG cache.
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Tab opens a list you can move through with the arrow keys, instead of only cycling
zstyle ':completion:*' menu select

# Lowercase input also matches uppercase: "doc" completes to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

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
