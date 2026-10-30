# dotfiles

My Arch Linux/Hyprland setup. Each folder is a [GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`: `nvim/.config/nvim` links to `~/.config/nvim`. Editing a linked file edits the repo.

## Install

Install `yay` (AUR: `yay-bin`) first.

```sh
git clone https://github.com/geoabrec/dotfiles.git ~/dotfiles
cd ~/dotfiles
grep -v '^#' packages.txt | yay -S --needed -
./install.sh
```

`install.sh` is safe to re-run. If a real file is in the way, it stops and names it. Move the file aside or into the repo, then run it again.

## One-time steps

- **SSH:** restore `~/.ssh` (keys and `allowed_signers`), put `AddKeysToAgent yes` in `~/.ssh/config`, and run `systemctl --user enable --now ssh-agent.socket`.
- **GitHub:** run `gh auth login` before you push.
- **tmux:** press `prefix + I` to install the plugins.
- **GTK (`nwg-look`):** theme `Adwaita-dark`, icons `Adwaita`, font `Adwaita Sans 11`.
- **Qt (`qt6ct`):** style `Fusion`, colour scheme `darker`.
- **Cursor:** `Bibata-Modern-Ice` at size 24, in `nwg-look` and as `XCURSOR_THEME` and `XCURSOR_SIZE` in `/etc/environment`.
- **Claude Code:** install it with its own installer, not pacman.
- **Codex:** run `codex login`, then use `/hooks` in Codex to trust `source-guard`. The guard stays off until you do. To test it, ask Codex to run `echo x > t.cpp` in learncpp. It must be refused.

## Packages

Each package is named after what it configures. The AI setup splits into three:

| Package | Holds |
| --- | --- |
| `agents` | Shared rules (`AGENTS.md`), skills and the `source-guard` hook |
| `claude` | Claude Code settings, status line, keybindings and `source-guard` mod |
| `codex` | Codex config and `source-guard` hook setup |

## Add a config

```sh
mkdir -p ~/dotfiles/foo/.config/foo
mv ~/.config/foo/foo.conf ~/dotfiles/foo/.config/foo/
```

Add `foo` to `PACKAGES` in `install.sh`, run `./install.sh`, and commit.

If the app also writes data to that folder, add the folder to the `mkdir -p` list in `install.sh`. Otherwise Stow links the whole folder and the data lands in the repo.

## Repair a replaced link

Some apps save by replacing the link with a plain file, such as kitty's theme picker and Claude Code's `/config`. `./install.sh check` lists those files. To repair one:

```sh
mv ~/.config/kitty/kitty.conf ~/dotfiles/kitty/.config/kitty/kitty.conf
./install.sh
git diff
```

## Credits

The zsh config started from [radleylewis/zsh](https://github.com/radleylewis/zsh) (MIT). Its licence is in `zsh/.config/zsh/LICENSE`.
