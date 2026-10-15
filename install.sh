#!/usr/bin/env bash
# Link every package into $HOME with GNU Stow.
#   ./install.sh         link everything (safe to re-run)
#   ./install.sh check   list links that an app replaced with a plain copy
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(claude fastfetch git hypr kitty mdv nvim pacman rofi tmux waybar zsh)

stow_all() { stow -d "$DOTFILES" -t "$HOME" "$@" "${PACKAGES[@]}"; }

check() {
    local pkg file rel target bad=0
    for pkg in "${PACKAGES[@]}"; do
        while IFS= read -r -d '' file; do
            rel="${file#"$DOTFILES/$pkg/"}"
            # Stow never links these, so they have no target to check.
            case "$rel" in
                README.* | LICENSE.* | COPYING | *.gitignore | *~) continue ;;
            esac
            target="$HOME/$rel"
            if [[ ! -e "$target" ]]; then
                echo "missing:  ~/$rel"; bad=1
            elif [[ "$(realpath "$target")" != "$(realpath "$file")" ]]; then
                echo "not a link to the repo:  ~/$rel"; bad=1
            fi
        done < <(find "$DOTFILES/$pkg" -type f -print0)
    done
    if (( bad )); then
        echo "Fix: move the copy over the repo file, then run ./install.sh again."
        return 1
    fi
    echo "OK: every file links into $DOTFILES"
}

install() {
    # Folders that also hold data outside the repo must exist as real folders.
    # Otherwise Stow links the whole folder ("folding") and apps would write
    # their history and caches into the repo.
    mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/state/zsh" \
             "$HOME/.cache/zsh" "$HOME/.claude/skills"

    # Dry run first: Stow never overwrites real files, it reports them instead.
    local out
    if ! out="$(stow_all --no -R 2>&1)"; then
        echo "$out"
        echo "Move those files out of the way (or into the repo), then re-run."
        exit 1
    fi
    stow_all -R

    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi

    echo "Linked: ${PACKAGES[*]}"
    echo
    # The one-time steps live in the README; print that section.
    sed -n '/^## One-time steps/,/^## /{/^## [^O]/!p}' "$DOTFILES/README.md"
}

case "${1:-}" in
    "") install ;;
    check) check ;;
    *) echo "usage: $0 [check]" >&2; exit 2 ;;
esac
