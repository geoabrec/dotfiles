# ~/.config/zsh/.zshenv

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
fi

# ---------- SSH agent ----------
# Agent started by systemd (ssh-agent.socket); holds the unlocked key for git signing/push
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/ssh-agent.socket"

# ---------- PATH ----------
# Drop duplicate entries, since every nested zsh and script reads this file again.
# -U only applies to assignments to the array path (tied to PATH), not to PATH=...
typeset -U path

# Personal binaries/scripts
path=("$HOME/.local/bin" $path)
