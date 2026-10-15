# zsh

Interactive zsh with vi mode, fzf, three plugins and the starship prompt.
Stow links `.zshenv` to `~/.zshenv` and `.config/zsh/` to `~/.config/zsh/`. This README and `LICENSE.radleylewis` sit at the package's top level, which Stow skips.

## Startup order

zsh reads its startup files in the order `zshenv` → `zprofile` → `zshrc` → `zlogin`, and only the ones that match the kind of shell:

| File | Script (`zsh file`, `zsh -c`) | Interactive (a kitty window) | Login + interactive (a tmux pane) | ly starting Hyprland |
| --- | :-: | :-: | :-: | :-: |
| `~/.zshenv`, the stub: sets `ZDOTDIR`, sources `$ZDOTDIR/.zshenv` | ✓ | ✓ | ✓ | ✓ |
| `/etc/zsh/zprofile`: runs `/etc/profile` (system PATH and the like) | | | ✓ | ✓ |
| `$ZDOTDIR/.zshrc` | | ✓ | ✓ | |

Arch ships no `/etc/zsh/zshenv` or `zshrc`, and this config has no `.zprofile` or `.zlogin`, so those steps do nothing. ly runs `/etc/ly/setup.sh` with zsh as a script, which reads `.zshenv`; the script then sources the `zprofile` files itself, like a login shell would, and starts Hyprland.

Why the stub: zsh looks for `.zshenv` in `$ZDOTDIR`, falling back to `~`. The stub in `~` sets `ZDOTDIR=~/.config/zsh`, so zsh then finds `.zshrc` there. But it never goes back for that folder's `.zshenv`, so the stub sources it by hand.

**Environment changes need a new login.** Hyprland gets its environment from ly's setup script, and everything Hyprland opens (kitty, waybar, Claude Code) inherits it. After you add, change or remove an `export` in `.zshenv`, log out and back in. Until then, programs that were already running keep the old value and pass it on to the shells they start.

## Files

| File | Read by | Contents |
| --- | --- | --- |
| `.zshenv` (→ `~/.zshenv`) | every zsh | the stub described above |
| `.config/zsh/.zshenv` | every zsh | XDG folders, `EDITOR`/`VISUAL`, `MANPAGER`, `SSH_AUTH_SOCK`, `PATH`; only quick, silent exports |
| `.config/zsh/.zshrc` | interactive shells | history, options, completion; sources the files below; zoxide and starship; the SSH key |
| `fzf.zsh` | `.zshrc` | fzf settings, `source <(fzf --zsh)`, the Ctrl-F picker |
| `aliases.zsh` | `.zshrc` | aliases only |
| `functions.zsh` | `.zshrc` | `cr` (compile and run C++) and `lf` (cd to where lf quit) |
| `plugins.zsh` | `.zshrc` | the plugin loader, `zplugin-update`, the three plugins |
| `keys.zsh` | `.zshrc` | vi mode and every key binding |
| `local.zsh` (optional, gitignored) | `.zshrc`, last | overrides for one machine only |

`.zshrc` loads them in this order: compinit → `fzf.zsh` → `aliases.zsh` → `functions.zsh` → `plugins.zsh` → `keys.zsh` → zoxide → starship → SSH key → `local.zsh`. The comment above each step in `.zshrc` says why it sits there.

Outside the repo:
- history: `~/.local/state/zsh/history`
- completion cache: `~/.cache/zsh/zcompdump`
- plugins: `~/.local/share/zsh/plugins/`
- prompt: the [`starship`](../starship/) package, `~/.config/starship.toml`

## Key bindings

### Insert mode

| Key | Does |
| --- | --- |
| Esc | normal mode; the prompt's `❯` turns into `❮` |
| Backspace, Ctrl-W, Ctrl-U | delete a character, a word, or back to the start of the line, also past where insert mode began |
| ↑ / ↓ | search history for lines containing what you've typed |
| → | accept the grey autosuggestion |
| Ctrl-← / Ctrl-→ | move a word left or right |
| Home / End / Delete | start or end of the line, delete the character under the cursor (in normal mode too) |
| Tab | completion menu (move with the arrow keys) |
| `**`Tab | fzf completion, e.g. `nvim **<Tab>` |
| Ctrl-R | fzf: search history |
| Ctrl-T | fzf: insert a file path (hidden files included) |
| Ctrl-F | fzf: insert a file path, without hidden files |
| Alt-C | fzf: cd into a subfolder |
| Ctrl-\\ | turn autosuggestions off or on |

### Normal mode

| Key | Does |
| --- | --- |
| `i` `a` `I` `A` | back to insert mode |
| `w` `b` `e` `0` `$` | motions, as in vim |
| `d` `c` `y` + motion or text object, `dd` `cc` `yy`, `p`, `x` | edit, as in vim |
| `u` | undo (no redo key: Ctrl-R opens fzf instead) |
| `iw` `aw` `iW` `aW` | word text objects, e.g. `ciw` |
| `i"` `a"` `i'` `a'` `` i` `` `` a` `` | quote text objects, e.g. `ci"` |
| `i(` `a(` `ib`, `i[` `a[`, `i{` `a{` `iB`, `i<` `a<` | bracket text objects, e.g. `da(` |
| `cs"'` / `ds"` / `ys` + motion + `"` | change, delete or add surrounding quotes or brackets, e.g. `ysiw"` |
| `v` / `V` | visual mode / visual line mode; `S"` in visual mode surrounds the selection |
| `k` / `j` | history substring search, like ↑ / ↓ |
| `/` | search history |
| Ctrl-E | edit the command line in nvim; save and quit to put it back |
| Ctrl-R, Ctrl-T, Alt-C | fzf, as in insert mode |

Esc switches mode instantly (`KEYTIMEOUT=1`). In normal mode zsh waits up to 0.4 s for the second key, so `cs`, `ds` and `ys` aren't mistaken for `c`, `d` and `y`.

## Plugins

| Plugin | Does |
| --- | --- |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | suggests the rest of the line from history, in grey; → accepts it |
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | colours the command line as you type; an unknown command shows up red |
| [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | ↑ / ↓ (and `k` / `j`) find history lines containing what you've typed |

`plugins.zsh` clones a missing plugin from GitHub into `~/.local/share/zsh/plugins/` the first time a shell starts (it prints `Installing …`), then sources it. They load in the order above; history-substring-search's README asks to come after syntax highlighting.

They aren't pinned to versions; they follow each project's default branch. To update, run `zplugin-update` (a `git pull --ff-only` in each) and then `exec zsh`.

## Tools it expects

[`../packages.txt`](../packages.txt) lists them. Its zsh section has starship, eza, bat, fzf, fd, ripgrep, zoxide, lf (the `lf` function) and mpv (`stream`). From other sections, the config also uses:
- nvim (`EDITOR`)
- git and openssh (the SSH key block)
- g++ from base-devel (`cr`)

## Credits

This config started as a copy of [radleylewis/zsh](https://github.com/radleylewis/zsh) (MIT; the notice is in [`LICENSE.radleylewis`](LICENSE.radleylewis)). From it come:
- the plugin loader and `zplugin-update`
- `fzf.zsh`, including the Ctrl-F picker
- most aliases (eza, bat, rg, `glog`, `gadog`), the `lf` function and `stream`
- the history, option and completion settings
- the Ctrl-←/→, Ctrl-\\ and ↑/↓ bindings
- the layout of `starship.toml`

The rest is mine:
- `cr`, the short git aliases, `c` and `e`
- the vi mode setup in `keys.zsh`
- the SSH key block
- the file layout and comments, from the [Plan 2 refactor](../docs/plan-2-zsh-refactor.md)
