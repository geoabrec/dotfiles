# ~/.zshenv: points zsh at ~/.config/zsh so nothing in /etc needs editing.
#
# zsh reads ~/.zshenv only while ZDOTDIR is unset. Once this file sets it,
# zsh reads .zprofile and .zshrc from $ZDOTDIR, but never that folder's
# .zshenv, which is why it is sourced by hand below.
export ZDOTDIR="$HOME/.config/zsh"
if [[ -r "$ZDOTDIR/.zshenv" ]]; then
  source "$ZDOTDIR/.zshenv"
fi
