# zsh's built-in vi mode: no plugin, so nothing resets these bindings later
bindkey -v

# Esc waits this long (in 1/100 s) for a longer key sequence; 1 makes mode switches instant
KEYTIMEOUT=1

# Normal mode waits 0.4 s instead, so cs, ds and ys (below) aren't cut off after c, d, y.
# Runs on every mode switch and at each new prompt (which starts in insert mode).
_vi_keytimeout() {
  if [[ $KEYMAP == vicmd ]]; then KEYTIMEOUT=40; else KEYTIMEOUT=1; fi
}
zle -N zle-keymap-select _vi_keytimeout
zle -N zle-line-init _vi_keytimeout

# Backspace, Ctrl-W and Ctrl-U cross the point where insert mode began
# (by default they stop there, which is surprising after Esc a)
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line

# Quote and bracket text objects: ci" da( yi{ ... (iw aw iW aW are built in)
autoload -Uz select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

# Surround, as in vim-surround: cs"' changes, ds" deletes, ys<motion>" and visual S add
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd cs change-surround
bindkey -M vicmd ds delete-surround
bindkey -M vicmd ys add-surround
bindkey -M visual S add-surround

# Ctrl-E in normal mode opens the command line in $EDITOR, for long commands
# (not v: that stays visual mode)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^E' edit-command-line

bindkey -M viins '^[[1;5C' forward-word
bindkey -M viins '^[[1;5D' backward-word

# Home, End and Delete. Unbound, their leading Esc would switch to normal mode and the
# rest of the sequence would run as vi commands. kitty and tmux send different codes.
for m in viins vicmd; do
  bindkey -M $m '^[[H'  beginning-of-line
  bindkey -M $m '^[[1~' beginning-of-line
  bindkey -M $m '^[[F'  end-of-line
  bindkey -M $m '^[[4~' end-of-line
  bindkey -M $m '^[[3~' delete-char
done

bindkey -M viins '^F' _fzf_file_no_hidden
bindkey -M viins '^\' autosuggest-toggle

bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
