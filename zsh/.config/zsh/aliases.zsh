# Personal aliases: git in two or three keystrokes
alias g='git status'
alias ga='git add'
alias gc='git commit'
alias gr='git restore'
alias grm='git remote'
alias gp='git push'
alias gpl='git pull'
alias gpo='git push origin'

# One-letter shortcuts for the commands typed most
alias c='clear'
alias e='exit'

# eza instead of ls: file-type icons, and a git column in the long listings
alias ls='eza --icons auto'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons auto --git'

# Tree view
alias tree='eza --tree --icons auto'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# bat instead of cat: syntax highlighting; piped into another command it prints plain text
alias cat='bat'

# =========================================================
# Core utilities
# =========================================================

# Colour on by default; rg also skips .gitignore'd and hidden files, unlike grep
alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'  # sizes in G and M instead of 1K blocks

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# =========================================================
# Editor
# =========================================================

alias vim='nvim'  # muscle memory: vim opens Neovim

# =========================================================
# Git
# =========================================================

# Short logs print and stay on screen; long ones open in less
alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'

# =========================================================
# Video
# =========================================================

# Show the V4L2 video device /dev/video4 full-screen with as little delay as possible
alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'
