# fd lists files faster than find and skips .gitignore'd ones; --hidden still includes dotfiles
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# One look for every fzf window: prompt on top, preview on the right
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

# Coloured preview through bat, capped at 500 lines so huge files stay fast
export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Key bindings (Ctrl-T, Ctrl-R, Alt-C) and **<Tab> completion, built into fzf
source <(fzf --zsh)

# Ctrl+F: like Ctrl-T but without hidden files, for picking project files without .git noise
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden
