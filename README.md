# dotfiles

My Arch Linux / Hyprland configuration, linked into place with GNU Stow.

Each top-level folder is a Stow *package* whose contents mirror `$HOME`: `zsh/.zshenv` becomes `~/.zshenv`, `nvim/.config/nvim/` becomes `~/.config/nvim`. The files live here, under git; `$HOME` only holds symlinks to them, so editing a config edits the repo.

## Layout

| Package | Configures |
| --- | --- |
| `claude` | Claude Code: `CLAUDE.md`, settings, status line, keybindings, the `study` and `test` skills, a local mod |
| `fastfetch` | fastfetch system summary |
| `git` | `~/.gitconfig` (SSH commit signing) and the global ignore file |
| `hypr` | Hyprland (`hyprland.lua`) |
| `kitty` | kitty terminal and its theme |
| `mdv` | `mdv`, a Markdown-to-browser viewer script, and its CSS and HTML template |
| `nvim` | Neovim (imported with its full history) |
| `pacman` | `makepkg.conf` overrides |
| `rofi` | rofi launcher |
| `starship` | starship prompt (`~/.config/starship.toml`), used by zsh and the Claude Code status line |
| `tmux` | tmux (plugins via TPM) |
| `waybar` | waybar bar and its auto-reload script |
| `zsh` | `~/.zshenv` stub that sets `ZDOTDIR`, and the zsh config in `~/.config/zsh` |

Also here: `install.sh` (links everything), `packages.txt` (what the configs need) and `docs/` (the plans this repo was built from).

How Stow links things:
- If the target folder doesn't exist, Stow links the whole folder ("folding"): `~/.config/nvim` → `~/dotfiles/nvim/.config/nvim`. New files in it land in the repo automatically.
- If the target folder already exists (like `~/.claude`), Stow links file by file.
- Stow never overwrites real files; it stops and reports a conflict instead.
- It skips `README.*`, `LICENSE.*` and `COPYING` at a package's top level, and `.git` and `.gitignore` anywhere.

## Install on a new machine

1. Install `yay` (AUR: `yay-bin`), then the packages:
   ```sh
   grep -v '^#' packages.txt | yay -S --needed -
   ```
2. Clone the repo (log in with `gh auth login` only if you'll push; `.gitconfig` uses gh for GitHub credentials):
   ```sh
   git clone https://github.com/geoabrec/dotfiles.git ~/dotfiles
   ```
3. Link everything:
   ```sh
   cd ~/dotfiles && ./install.sh
   ```
   It does a dry run first and stops if a real file is in the way. Move that file aside (or into the repo) and run it again. It is safe to re-run.
4. Do the one-time steps below; `install.sh` prints them too.

## One-time steps

- Restore `~/.ssh` (keys and `allowed_signers`) and put `AddKeysToAgent yes` in `~/.ssh/config`.
- Start the SSH agent: `systemctl --user enable --now ssh-agent.socket`.
- In tmux, press `prefix + I` to install the plugins.
- Create `~/.claude/about-me.md`: personal context that `CLAUDE.md` imports and that stays out of git. Include the lines naming the practice folder and the notes folder; the `study` and `test` skills read them.
- Set the themes, which their GUI tools own and so aren't in the repo:
  - GTK (with `nwg-look`): theme `Adwaita-dark`, icons `Adwaita`, font `Adwaita Sans 11`
  - Qt (with `qt6ct`): style `Fusion`, colour scheme `darker`
  - Cursor: `Bibata-Modern-Ice` at size 24, the same name everywhere: in `nwg-look` (GTK), and as `XCURSOR_THEME` and `XCURSOR_SIZE` in `/etc/environment`. Hyprland also sets it on start.

## Adding a new config

1. Create the package with the same path it has under `~`, and move the file in:
   ```sh
   mkdir -p ~/dotfiles/foo/.config/foo
   mv ~/.config/foo/foo.conf ~/dotfiles/foo/.config/foo/
   ```
2. Add `foo` to `PACKAGES` in `install.sh`, run `./install.sh`, and commit.

## When a link is replaced by a copy

Some apps save a file by writing a new one in its place, which turns the symlink into a plain file. The repo then stops seeing changes. kitty's theme picker and Claude Code's `/config` are likely to do this.

`./install.sh check` lists every file that is missing or no longer links into the repo, and prints only `OK` otherwise. To fix one, move the copy over the repo file, run `./install.sh`, and review it with `git diff`:

```sh
mv ~/.config/kitty/kitty.conf ~/dotfiles/kitty/.config/kitty/kitty.conf
./install.sh
```

## Credits

The zsh config started from [radleylewis/zsh](https://github.com/radleylewis/zsh) (MIT); its licence is kept in `zsh/.config/zsh/LICENSE`.


