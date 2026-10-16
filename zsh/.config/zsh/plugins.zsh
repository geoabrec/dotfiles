# Plugins are downloaded data, not config, so they live outside the repo
ZPLUGINDIR="$XDG_DATA_HOME/zsh/plugins"

# A minimal plugin manager: clone a plugin on first use, then source it.
# Usage: _zplugin_load <github-user> <repo>
_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

# Plugins never update on their own; run this to pull all of them
zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

# history-substring-search's README: load it after syntax highlighting
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zdharma-continuum fast-syntax-highlighting
_zplugin_load zsh-users zsh-history-substring-search
