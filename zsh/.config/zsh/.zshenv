# ~/.config/zsh/.zshenv: environment for every zsh, scripts included (sourced by the ~/.zshenv stub).
# Only quick, silent exports belong here. Programs started from the login shell (Hyprland and
# everything it launches) keep these values until the next login.

# ---------- XDG base directories ----------
# Set explicitly so every tool, and the rest of this config, agrees on where things go
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
# Coloured man pages; the check keeps plain less on a machine without bat
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
