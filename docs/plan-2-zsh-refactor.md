# Plan 2: zsh refactor

Written 2026-10-15 by Opus 5.5 for Sonnet 5.5 (effort: high) to implement.
Start only after [Plan 1](plan-1-dotfiles-repo.md) is done. All work happens in `~/dotfiles/zsh/`.

## Goal

Keep the same daily behaviour with less code, and make sure the user understands every line.

- **Today:** about 300 lines across 7 files, a third of it unused or written for other machines (macOS, Ubuntu, nvm). It loads a vi-mode plugin that resets keybindings and needs workarounds.
- **After:** only what the user uses, a one-line "why" comment on every block, and a README that explains the whole setup.

## Rules for the implementer

- Make one commit per numbered step. After each one:
  1. run the checks
  2. show `git show --stat`
  3. explain the change in 2–4 plain sentences, focusing on *why*
  4. wait for the user's go

  The user reads every diff; that's how they'll learn the config.
- Never leave the shell broken. After every edit, run `zsh -n <file>` on each changed file, then `zsh -i -c exit`, which must print nothing. Keep a working terminal open.
- Keep the user's own code (`cr`, `stream`, the `lf` wrapper, the git aliases) exactly as written. Move it if a step says so; don't rewrite it.
- Don't add features. Items marked *optional* need the user's yes.
- Ask before deleting anything outside the repo.

## User's decisions

- **Vi mode:** keep the vim motions, but switch from the `zsh-vi-mode` plugin to zsh's built-in vi mode.
- **lf:** keep it, along with its `lf` wrapper function (it's installed). There's no `~/.config/lf`, so the `LF_ICONS` block goes.
- **Aliases:** keep `grep` → `rg` and `cat` → `bat`.
- **pi:** gone. Remove its environment variable and delete `~/pi-archive-2026-10-11.tar.gz`; ask before deleting. (Checked 2026-10-15: the archive holds old pi sessions, undo snapshots, a theme, pi's own settings, and older copies of the study/test skills. The current skills live in `~/.claude/skills`.)
- **No new features.**

## Facts checked on 2026-10-15

- No GPG secret keys (`gpg --list-secret-keys` is empty). Git signs with SSH.
- fzf 0.74.5 (`fzf --zsh` exists since 0.48). starship 1.26.0 has `c`, `cpp` and `python` modules.
- Go, rustup and php are not installed. node is, from pacman.
- `zoxide` 0.10.0 is installed from pacman, but a manually installed binary in `~/.local/bin/zoxide` (August) hides it because it comes first in PATH.
- Startup time: about 60 ms (`time zsh -i -c exit`).

## Step 0: baseline (no commit)

From an interactive shell, save the following into the scratchpad (not the repo):
- the output of `alias`
- `bindkey -L -M <map>` for each of `main`, `viins`, `vicmd`, `visual` and `viopp`
- `print -l ${(k)functions}`
- `env | sort`
- `setopt`
- `time zsh -i -c exit`, run 5 times

Step 9 compares against these.

## Step 1: remove unused code

Each item below is unused on this machine. Delete it along with its comment.

- `.zshrc`: the `nvm` block. There's no `~/.nvm`.
- `.zshrc`: the `LF_ICONS` block. There's no `~/.config/lf`.
- `.zshrc`: `export PI_CLAUDE_CODE_PROVIDER_ACKNOWLEDGED_PLATFORM=...`.
- `.zshenv`: `GPG_TTY=$(tty)`. It runs in every zsh, including scripts, where its value becomes the text "not a tty", and there are no GPG keys.
- `.zshenv`: the `batcat` branch of `MANPAGER`. That's the Ubuntu package name; keep the `bat` line.
- `aliases.zsh`: the `dotfiles` alias. It was for a bare-repo setup that never existed; Plan 1 used Stow instead.

**Outside the repo** (ask first; all are in the Plan 1 backup):
- `~/.zprofile`. zsh never reads it, because it looks for `$ZDOTDIR/.zprofile`. Its cursor settings are already handled by Hyprland (`hyprctl setcursor`).
- `~/.zhistory` (299 lines) and `~/.histfile` (1,089 lines). Old history files from before the current `~/.local/state/zsh/history`.
- `~/.local/bin/zoxide`. Afterwards check that `which -a zoxide` shows only `/usr/bin/zoxide`, and that `z` still jumps to directories.
- `~/pi-archive-2026-10-11.tar.gz`.

## Step 2: fzf in one line

- Replace the five platform-specific `if` blocks (Homebrew ×2, Arch, Ubuntu, git clone) with `source <(fzf --zsh)`. This one line sets up Ctrl-T, Ctrl-R, Alt-C and `**<Tab>` completion.
- Put it in `fzf.zsh`, after the `FZF_*` variables and before the Ctrl-F widget.
- Check: Ctrl-T, Ctrl-R and Alt-C work in both insert and normal mode, and `nvim **<Tab>` completes.

## Step 3: built-in vi mode replaces zsh-vi-mode

Create `keys.zsh` to replace `bindings.zsh`. Requirements:

- **Mode:** `bindkey -v`, plus `KEYTIMEOUT=1`, so Esc switches mode in 10 ms instead of the default 0.4 s.
- **Normal editing keys in insert mode.** By default, zsh's insert-mode Backspace stops where you entered insert mode, which is surprising after `Esc a`. Bind:
  - `^?` and `^H` → `backward-delete-char`
  - `^W` → `backward-kill-word`
  - `^U` → `backward-kill-line`
- **Text objects:**
  - `iw`, `aw`, `iW` and `aW` are built in.
  - Add quote and bracket objects (`ci"`, `da(`, `yi{`…) with the `select-quoted` and `select-bracketed` widgets.
  - Add surround (`cs`, `ds`, `ys`, and `S` in visual mode) with the `surround` widget.
  - All three ship with zsh. `man zshcontrib`, section "ZLE Functions", shows the setup and binding loops.
- **Editor:** `v` in normal mode opens the command line in `$EDITOR` (`edit-command-line`). This replaces zsh-vi-mode's `vv`.
- **Cursor.** The user wants a blinking block in every mode, which is the current setting. Built-in vi mode doesn't change the cursor, so the terminal default applies. Check that it's a blinking block in kitty, inside tmux, and after quitting nvim. Only if it isn't, add a minimal cursor reset; *optional*, ask first.
- **Existing bindings** (moved out of the `zvm_after_init` hook, which goes away with the plugin):
  - Ctrl-← and Ctrl-→: word motions
  - Ctrl-F: `_fzf_file_no_hidden`
  - `Ctrl-\`: `autosuggest-toggle`
  - ↑ and ↓: history-substring-search
  - also `k` and `j` in normal mode → history-substring-search (the plugin's README recommends this)
- **Remove:**
  - `zvm_config`, all `ZVM_*` variables, and the `zsh-vi-mode` line in `plugins.zsh`
  - `FUNCNEST=100` in `prompt.zsh` (an upstream workaround with no explanation, most likely for zsh-vi-mode; check that no "maximum nested function level" error shows up without it)
  - the plugin's clone folder
- **Order:** `keys.zsh` must be sourced *after* `plugins.zsh`, so the plugin widgets exist when they're bound (see Step 4).

**Checklist for the user to try:**
- Esc shows `❮` in the prompt.
- Insert mode: `i`, `a`, `A`, `I`.
- Motions: `w`, `b`, `e`, `0`, `$`.
- Edits: `dw`, `ciw`, `ci"`, `da(`, `cs"'`, `ds"`, and `u` to undo.
- `/` searches history in normal mode.
- `v` opens nvim.
- Backspace works after `Esc a`.
- ↑ searches by substring.
- Ctrl-R works.
- → accepts an autosuggestion.

## Step 4: file layout and load order

Pure reorganisation: move code, and don't change what it does.

| File | Read by | Contents |
| --- | --- | --- |
| `.zshenv` | every zsh, scripts included | `typeset -U path` (moved here, before the PATH edits), XDG dirs, `EDITOR`/`VISUAL`, `MANPAGER`, `SSH_AUTH_SOCK`, PATH. Nothing that prints or is slow. |
| `.zshrc` | interactive shells | options, history, completion; sources the modules below in order; zoxide and starship init; SSH key; `local.zsh` |
| `fzf.zsh` | `.zshrc` | fzf settings, `source <(fzf --zsh)`, the Ctrl-F widget |
| `aliases.zsh` | `.zshrc` | aliases only |
| `functions.zsh` | `.zshrc` | `cr` and `lf`, moved from `aliases.zsh` unchanged |
| `plugins.zsh` | `.zshrc` | the loader and 3 plugins |
| `keys.zsh` | `.zshrc` | vi mode and every binding |

`prompt.zsh` goes away. Its content becomes two lines in `.zshrc`: `VIRTUAL_ENV_DISABLE_PROMPT=1` and the starship init.

Order inside `.zshrc`. Write the reason for each step as a comment.

1. Options and history.
2. `compinit`. It must come before anything that calls `compdef` (`aliases.zsh` has `compdef eza=ls`), and before fzf's completion.
3. `fzf.zsh`. It defines widgets; fzf binds its keys in the emacs, viins and vicmd keymaps itself.
4. `aliases.zsh`, then `functions.zsh`.
5. `plugins.zsh`. Syntax highlighting goes after the custom widgets are defined, so it can wrap them.
6. `keys.zsh`. All widgets exist by now.
7. zoxide init. Its docs say to put it after `compinit`, near the end.
8. Starship init.
9. SSH key (Step 7).
10. `local.zsh`, if present: machine-only overrides, gitignored.

Check: after a Ctrl-R or Ctrl-T insert, syntax highlighting still colours the line. If it doesn't, try loading the plugins later and tell the user what changed.

## Step 5: plugins out of the repo

- `ZPLUGINDIR="$XDG_DATA_HOME/zsh/plugins"`. Plugins are downloaded data, not config, and this keeps the repo clean.
- `mv` the existing clones there, then delete the `zsh/.config/zsh/plugins/` line from `~/dotfiles/.gitignore`.
- Load order: `zsh-autosuggestions`, then `fast-syntax-highlighting`, then `zsh-history-substring-search`. History-substring-search's README says to load it after syntax highlighting.
- Keep `zplugin-update`. *Optional:* pin each plugin to a tag. The default is no.
- Check that a fresh install works: `XDG_DATA_HOME=<scratchpad>/data zsh -i -c exit` clones all three, and a second run is silent.

## Step 6: starship gets its own package

- `git mv zsh/.config/zsh/starship.toml starship/.config/starship.toml`. That's starship's default location, so `STARSHIP_CONFIG` comes out of `.zshenv`.
- Stow `starship`, and add it to `PACKAGES` in `install.sh` and to the README layout table.
- Remove modules for tools that aren't installed:
  - `golang`, `rust` and `php`
  - the `os.symbols` entries for Ubuntu, Artix, CachyOS and macOS (keep Arch)
  - update `format` to match
  - keep `nodejs`
- *Optional:* ask whether the user wants `cpp` and `python` modules for learncpp and college work.
- Check: in a git repo, the prompt shows the directory, branch and status, `❯` (red after a failed command) and `❮` in normal mode.

## Step 7: SSH key block

- Keep it, but drop the `[[ -o interactive ]]` guard: `.zshrc` only runs in interactive shells anyway.
- Rewrite the comment to give the real reason. `AddKeysToAgent yes` in `~/.ssh/config` only adds the key when ssh connects somewhere. Git commit signing (`ssh-keygen -Y sign`) needs the key in the agent beforehand. So the first terminal after each boot asks for the passphrase.
- Also explain `ssh-add -l`'s exit codes: 0 means the agent has keys, 1 means it has none, 2 means there's no agent.

## Step 8: comments, README, credits

- Replace the upstream header in `.zshrc` (author and tool list) with three lines: what the file is, when zsh reads it, and a pointer to the README.
- Give every block a one-line comment saying *why* it exists, not what the code obviously does. Keep the existing `# ====` section banners.
- Delete the upstream `README.md` and `.gitignore` inside `.config/zsh/`; the repo root `.gitignore` covers it.
- Move `LICENSE` to `zsh/LICENSE.radleylewis`. That's the package's top level, which Stow ignores. MIT requires keeping the notice wherever substantial parts are reused, and the plugin loader and Ctrl-F picker come from radleylewis/zsh.
- Write `zsh/README.md` (top level, so Stow ignores it):
  - startup order: which files load for login, interactive and script shells, including the `~/.zshenv` stub from Plan 1
  - a file map
  - a keybindings cheat sheet covering vi mode and the custom bindings
  - the plugins: what each does, and updating with `zplugin-update`
  - the tools the config expects (link to `../packages.txt`)
  - credits

## Step 9: final check (no commit unless something needs fixing)

- Compare with the Step 0 baseline:
  - aliases: only `dotfiles` should be gone
  - bindings: list the vi-mode differences
  - environment: `STARSHIP_CONFIG`, `GPG_TTY`, the pi variable and `NVM_DIR` should be gone
  - startup time: should be at or below the baseline
- Run:
  - `zsh -n` on every file
  - `zsh -i -c exit` (silent)
  - `env -i HOME=$HOME TERM=$TERM USER=$USER zsh -l -i -c exit` (silent)
  - `~/dotfiles/install.sh check` (clean)
- The user tries the Step 3 checklist plus:
  - `cr` on a learncpp file
  - quitting `lf` leaves the shell in the last directory
  - `z <dir>`, `ll`, `g`
  - a new tmux pane and a new kitty window
- Report the line count before and after.
