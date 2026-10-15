# Plan 1: dotfiles repo

Written 2026-10-15 by Opus 5.5 for Sonnet 5.5 (effort: high) to implement.
Plan 2, the zsh refactor, comes after this one: [plan-2-zsh-refactor.md](plan-2-zsh-refactor.md).

## Goal

Put every config the user wrote into one git repo, `~/dotfiles`, linked into place with GNU Stow.
Configs keep their content in this plan, except the steps marked **change**. Cleaning up zsh is Plan 2.

## Rules for the implementer

- Work one phase at a time. At the end of each phase, report what you did and what you checked, then wait for the user's go.
- Ask before:
  - anything that needs `sudo` (give the user the command to type as `! <command>`)
  - deleting anything
  - any GitHub action (create, push, archive)
- Don't touch a live file until the Phase 0 backup exists.
- Commits are signed with SSH (`commit.gpgsign = true`). If signing fails, stop and ask. Never use `--no-gpg-sign`.
- Make one commit per package or change, with a message that says what and why.
- Explain each step in a sentence or two. The user wants to understand the setup, not just have it.
- Don't add tools, packages or files that aren't listed here. If something seems missing, ask.
- `pull.rebase = true` is set globally, so never `git pull` unrelated histories. Use `fetch` + `merge` (Phase 2).

## Decisions already made

| Decision | Choice |
| --- | --- |
| Linking tool | GNU Stow |
| Repo | `~/dotfiles`, branch `main` |
| GitHub | `geoabrec/dotfiles`, private (may go public later) |
| Neovim | Merge `~/.config/nvim` with its history, then archive `geoabrec/neovim-config` |
| zsh history | Start fresh: the radleylewis/zsh fork history is not imported (it stays in the backup) |

## How Stow works (reuse this in the README)

- Each top-level folder in the repo is a *package*, and its contents mirror `$HOME`.
- `stow -d ~/dotfiles -t ~ zsh` creates symlinks in `~` for everything in `zsh/`.
- If the target folder doesn't exist, Stow links the whole folder ("folding"): `~/.config/zsh` → `~/dotfiles/zsh/.config/zsh`.
- If the target folder already exists (like `~/.claude`), Stow links file by file.
- Stow never overwrites real files. That's why each original is moved aside before stowing.
- Stow's default ignore list skips:
  - `README.*`, `LICENSE.*` and `COPYING` at a package's top level, so a `zsh/README.md` is never linked into `~`
  - `.git` and `.gitignore` anywhere
- Don't create `.stow-local-ignore` files: one would replace those defaults.

## Target layout

```text
~/dotfiles/
├── README.md        what's here, how to install, layout, credits
├── install.sh       links all packages; `./install.sh check` finds broken links
├── packages.txt     pacman/AUR packages the configs need
├── .gitignore
├── docs/            these two plans
├── claude/.claude/  CLAUDE.md, settings.json, statusline.sh, keybindings.json,
│                    skills/study/, skills/test/, mods/
├── fastfetch/.config/fastfetch/config.jsonc
├── git/.gitconfig
├── git/.config/git/ignore
├── hypr/.config/hypr/hyprland.lua
├── kitty/.config/kitty/   kitty.conf, current-theme.conf, dark-theme.auto.conf
├── mdv/.config/mdv/       style.css, template.html
├── mdv/.local/bin/mdv
├── nvim/.config/nvim/     (with history)
├── pacman/.config/pacman/makepkg.conf
├── rofi/.config/rofi/config.rasi
├── tmux/.tmux.conf
├── waybar/.config/waybar/ auto-reload.sh, config.jsonc, style.css
└── zsh/.zshenv (stub, Phase 4) and zsh/.config/zsh/
```

**Left out on purpose** (don't add these):
- `waypaper`, `gtk-3.0`, `gtk-4.0`, `qt6ct`, `nwg-look`: their GUI apps rewrite these files. The README records the theme names instead.
- `ghostty`: not installed.
- `lazygit` and `mpv`: their configs are empty.
- `~/.ssh`: it holds the keys.
- Everything else in `~/.claude`: history, sessions, `projects/` (memory), `skills/synced/` (managed by claude.ai), and `~/.claude.json` (login state).
- `~/.tmux/plugins`: TPM installs these.

## Phase 0: before touching anything

1. **Fix paths that are about to be committed.** The notes repo was reorganised and three files still point at old paths:
   - `~/.claude/CLAUDE.md`: `geomar-database/Profile.md` → `geomar-database/notes/Profile.md`.
   - `~/.claude/skills/study/SKILL.md` and `~/.claude/skills/test/SKILL.md`:
     - the same Profile fix
     - the practice folder `geomar-database/practice` → `geomar-database/notes/.practice`
   - Show the user the diff.
2. **Profile.md out of git** (the user asked for this). In `~/Desktop/geomar-database`, add `notes/Profile.md` to `.gitignore`.
   - That repo has an uncommitted reorganisation (11 deletions, 4 new folders). Ask whether the user wants to commit it themselves or have you do it.
   - If you commit it, don't add `notes/Profile.md`.
   - Older versions of `Profile.md` stay in that repo's history. It has no remote, so nothing is exposed.
3. **Neovim has uncommitted work**: `lua/plugins/editing.lua`, `treesitter.lua` and `ui.lua` are modified, and `after/` is untracked. Only committed history gets merged, so ask the user to commit or discard it. Don't commit it for them unless they say so.
4. **Tools.** Ask the user to run `! sudo pacman -S --needed stow git-filter-repo`. git-filter-repo is only needed in Phase 2; offer to remove it afterwards.
5. **Backup.**
   - Set `B=~/dotfiles-backup-<today>`.
   - `cp -a` into it every source path listed in Phase 3, plus `~/.config/nvim`, `~/.config/zsh` (including its `.git` and `plugins/`), `~/.zprofile` and `/etc/zsh/zshenv`.
   - Keep paths relative to `$HOME`, e.g. `$B/.config/zsh`; `/etc/zsh/zshenv` goes to `$B/etc/zsh/zshenv`.
   - Show the user the tree.
   - Keep the backup until the user has used the new setup for about a week.
6. Tell the user to keep one terminal with a working shell open until Phase 4 passes.

## Phase 1: skeleton

- `git init -b main ~/dotfiles`
- `.gitignore`:
  - `*.zwc` and `.zcompdump*`
  - `zsh/.config/zsh/plugins/` (Plan 2 moves the plugins out of the repo and drops this line)
  - `zsh/.config/zsh/local.zsh`
  - `*.swp` and `*~`
- `README.md`: a one-line description and empty section headings (Phase 5 fills them in).
- Move this plan and Plan 2 from `~/Desktop/geomar-database/notes/dotfiles/` to `~/dotfiles/docs/`, then remove the empty `notes/dotfiles/` folder.
- Commit: `Start dotfiles repo`.

## Phase 2: Neovim, with history

1. `git clone --no-local ~/.config/nvim <scratchpad>/nvim-import`
2. In the clone: `git filter-repo --to-subdirectory-filter nvim/.config/nvim`. This rewrites every commit so its files sit under `nvim/.config/nvim/`.
3. In `~/dotfiles`: `git fetch <scratchpad>/nvim-import <branch>`, then `git merge --allow-unrelated-histories FETCH_HEAD -m "Import neovim-config with its history"`. Check the branch name first.
4. Expected side effect: the rewritten commits lose their SSH signatures. The merge commit is signed. Tell the user.
5. Check: `git log --oneline -- nvim/` lists the old commits, and `git log --follow nvim/.config/nvim/init.lua` works.
6. Make a directory under `$B/replaced/`, then in one command: `mv ~/.config/nvim $B/replaced/.config/nvim && stow -d ~/dotfiles -t ~ nvim`.
7. Check:
   - `readlink ~/.config/nvim`
   - `nvim --headless +qa` prints no errors
   - ask the user to open nvim once and check plugins load
8. Don't archive the GitHub repo yet (Phase 7).

Side note for the user: Claude Code keeps project memory per path (`~/.claude/projects/-home-geomar--config-nvim`). If Claude Code resolves the symlink, that memory may stop loading in `~/.config/nvim`. Check it the next time Claude is opened there. It doesn't block anything.

## Phase 3: one package at a time

For each row, in order (lowest risk first, zsh last):

1. `mkdir -p` the package path, then `cp -a` **only the listed files** into it.
2. `git add <pkg>` and commit `Add <pkg> config`.
3. In a **single command** (so the program is never left without its config): `mv` the live original to `$B/replaced/<same relative path>`, then `stow -d ~/dotfiles -t ~ <pkg>`.
4. Run the check, then go to the next row.

Where a folder holds only the listed files plus junk (the kitty `.bak` files), move the whole folder. The junk then sits in the backup, and Stow folds the folder.

| # | Package | Live source | Check |
| --- | --- | --- | --- |
| 1 | git | `~/.gitconfig`, `~/.config/git/ignore` | `git config --show-origin user.email` resolves through the link |
| 2 | pacman | `~/.config/pacman/makepkg.conf` | `cat` it through the link |
| 3 | mdv | `~/.config/mdv/`, `~/.local/bin/mdv` (only this file; `~/.local/bin` also holds `claude` and `zoxide`, which stay) | user runs `mdv` on a note |
| 4 | fastfetch | `~/.config/fastfetch/config.jsonc` | `fastfetch` runs |
| 5 | tmux | `~/.tmux.conf` | `tmux source-file ~/.tmux.conf` in a running session, no errors |
| 6 | kitty | `~/.config/kitty/` (`kitty.conf`, `current-theme.conf`, `dark-theme.auto.conf`; the two `.bak` files go to the backup) | user opens a new kitty window |
| 7 | rofi | `~/.config/rofi/config.rasi` | user opens the launcher |
| 8 | waybar | `~/.config/waybar/` | `pkill -SIGUSR2 waybar` reloads it; user sees the bar |
| 9 | hypr | `~/.config/hypr/hyprland.lua` | `hyprctl reload`, then `hyprctl configerrors` is empty |
| 10 | claude | see below | see below |
| 11 | zsh | see below | see below |

**claude (row 10):**
- Files: `CLAUDE.md`, `settings.json`, `statusline.sh`, `keybindings.json`, `skills/study/`, `skills/test/`, `mods/`. Look inside `mods/` first; if it has `node_modules/` or build output, add those to `.gitignore`.
- **Change, done before the first commit so it never enters history** (confirm with the user first). The `# About me` section of `CLAUDE.md` holds personal details: university, dates, where the user wants to work, a visa note.
  - Move those bullets into `~/.claude/about-me.md`, a plain file that is **not** in the repo.
  - Replace the section body with the import line `@~/.claude/about-me.md`.
  - Check that the import works: in a new Claude session, `/memory` shows the import, or Claude can say which university the user starts at. If it doesn't resolve, stop and tell the user.
- `~/.claude` stays a real folder, so Stow links each item separately. Claude Code is running and reads these files, so keep the move and stow in one command.
- Watch for this: Claude Code may save `settings.json` by replacing the file, which turns the symlink into a plain file (kitty's theme picker may do the same to `kitty.conf`). After the user changes a setting with `/config`, run `./install.sh check` (Phase 5). If it happens, document it in the README along with the fix: move the new file into the repo, then restow.
- Check: a new `claude` session in another terminal shows the status line, and `/memory` lists `CLAUDE.md`.

**zsh (row 11):**
- Copy `~/.config/zsh/` **without** `.git/`.
- `plugins/` comes along but is gitignored.
- The upstream `README.md` and `LICENSE` come in unchanged; Plan 2 replaces them.
- The working tree is the conflict-free version, so commit that. The upstream `HEAD` commit still contains merge conflict markers, which is one more reason not to import that history.
- Checks:
  - `zsh -i -c exit` prints nothing
  - `zsh -i -c 'echo $ZDOTDIR; alias | wc -l'` gives the same alias count as before
  - the user opens a new kitty window and a new tmux pane

## Phase 4: ZDOTDIR without editing /etc

Right now `/etc/zsh/zshenv` sets `ZDOTDIR`. No package owns that file: it was added by hand, following the upstream README. That means editing a file as root on every new machine. Replace it with a stub inside the repo:

1. **Change.** Create `zsh/.zshenv` (stowed to `~/.zshenv`). It does two things:
   - sets `ZDOTDIR="$HOME/.config/zsh"`
   - sources `$ZDOTDIR/.zshenv` if readable

   Comment it: zsh only reads `~/.zshenv` while `ZDOTDIR` is unset. Once the stub sets it, zsh reads `.zprofile` and `.zshrc` from the new folder, but never that folder's `.zshenv`, which is why the stub sources it. (The `XDG_CONFIG_HOME` default that `/etc/zsh/zshenv` set is already in `~/.config/zsh/.zshenv`.)
2. Commit, then `stow -R -d ~/dotfiles -t ~ zsh`.
3. The user runs `! sudo rm /etc/zsh/zshenv`. The backup copy is in `$B/etc/zsh/zshenv`.
4. Checks:
   - `env -i HOME=$HOME TERM=$TERM USER=$USER zsh -l -i -c 'echo $ZDOTDIR $EDITOR; print -l $path | head -3'` shows `/home/geomar/.config/zsh`, `nvim`, and `~/.local/bin` first.
   - `zsh -i -c exit` prints nothing.
   - The user opens a new kitty window, then logs out and back in through ly and runs `echo $ZDOTDIR $PATH` in a new terminal.
5. Leave `~/.zprofile` alone; Plan 2 deals with it.

## Phase 5: install.sh, packages.txt, README

**`install.sh`** (bash, `set -euo pipefail`, short and commented):
- `PACKAGES=(...)`: every package from Phases 2–3.
- With no argument:
  1. `mkdir -p ~/.local/state/zsh ~/.cache/zsh`
  2. `stow --no --verbose` (a dry run) for all packages. If it reports conflicts, print them and exit.
  3. `stow -R` for all packages.
  4. Clone TPM into `~/.tmux/plugins/tpm` if it's missing.
  5. Print the one-time steps from the README.
- `./install.sh check`: for every file in every package, compare `realpath ~/<path>` with the repo path, and print the ones that differ (an app replaced the link with a copy). Print nothing else when everything is fine, apart from a one-line OK.
- It does **not** run `systemctl` or `sudo`. Those are one-time steps in the README.
- Test 1: `./install.sh check` on this machine is clean.
- Test 2 (portability): `HOME=<scratchpad>/fakehome ./install.sh`. Every link is created inside the fake home, and `HOME=<scratchpad>/fakehome ./install.sh check` is clean. Delete the fake home afterwards.

**`packages.txt`:**
- One package per line, with `#` comment lines grouping them by config.
- List only what the configs actually call: read them, then confirm each with `pacman -Qi`, and use `pacman -Qm` to spot AUR packages.
- Not a full `pacman -Qqe` dump.
- Install line for the README: `grep -v '^#' packages.txt | yay -S --needed -`.

**`README.md`**, kept short:
- what this is (one paragraph)
- a layout table (package → what it configures)
- install on a new machine:
  1. install the packages
  2. clone the repo
  3. run `./install.sh`
  4. one-time steps:
     - `systemctl --user enable --now ssh-agent.socket`
     - in tmux, `prefix + I` to install the plugins
     - create `~/.claude/about-me.md`
     - put `AddKeysToAgent yes` in `~/.ssh/config`
     - set the GTK, Qt and cursor themes (read the current names from `~/.config/gtk-3.0/settings.ini` and `~/.config/qt6ct/qt6ct.conf`)
- adding a new config: move it into a package, then `stow` it
- the "link replaced by a copy" caveat and `./install.sh check`
- credits: the zsh config started from [radleylewis/zsh](https://github.com/radleylewis/zsh) (MIT)

Make one commit per file.

## Phase 6: small fixes

Make each fix its own commit, and show the diff before committing. Ask before each one.

- `git/.gitconfig`: `defaultBranh` → `defaultBranch`. The typo means git currently ignores the setting without warning.
- `kitty/.config/kitty/kitty.conf`: more than 3,300 of its lines are kitty's default commented-out template, and only 16 are real settings. Offer to cut it down to those 16 lines with short comments.
- Delete `~/.config/ghostty` (ghostty isn't installed).

## Phase 7: GitHub

Ask before each step.

1. `gh repo create geoabrec/dotfiles --private --source ~/dotfiles --push --description "<one line>"`.
2. Once the user confirms the merged Neovim history looks right: `gh repo archive geoabrec/neovim-config --yes`. The local `~/.config/nvim` remote still uses the old username `geomarabreuc`; that doesn't matter now, because the folder is a link into `~/dotfiles`.
3. Tell the user that every commit shows their email address (`user.email`). If they want it hidden before going public, GitHub's noreply address can be set as `user.email` for new commits; old commits keep the current address. It's their call; don't change it.

## Before making the repo public (later, when the user asks)

- Review **history**, not just the current files: `git log -p | grep -inE 'pucmm|visa|dominican|salary'` and a read through `claude/`.
- Then `gh repo edit geoabrec/dotfiles --visibility public --accept-visibility-change-consequences`.

## Rollback

- One package: `stow -d ~/dotfiles -t ~ -D <pkg>`, then `mv $B/replaced/<path> ~/<path>`.
- ZDOTDIR: `sudo cp $B/etc/zsh/zshenv /etc/zsh/zshenv`, then delete the `~/.zshenv` link.
- Everything: unstow every package, then copy back from the Phase 0 copy in `$B`.

## Done when

- `./install.sh check` is clean and the fake-home test passes.
- zsh, nvim, tmux, kitty, Hyprland, waybar, rofi and Claude Code all start normally.
- The repo is on GitHub (private), and the backup is kept for a week.
