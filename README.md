# dotfiles

My Arch Linux/Hyprland setup. Each folder is a
[GNU Stow](https://www.gnu.org/software/stow/) package that mirrors `$HOME`:
`nvim/.config/nvim` links to `~/.config/nvim`. Editing a linked file edits the
repo.

## Install

Install `yay` (AUR: `yay-bin`) first.

```sh
git clone https://github.com/geoabrec/dotfiles.git ~/dotfiles
cd ~/dotfiles
grep -v '^#' packages.txt | yay -S --needed -
./install.sh
```

`install.sh` is safe to re-run. If a real file is in the way, it stops and names
it. Move the file aside or into the repo, then run it again.

## One-time steps

- **SSH:** restore `~/.ssh` (keys and `allowed_signers`), put
  `AddKeysToAgent yes` in `~/.ssh/config`, and run
  `systemctl --user enable --now ssh-agent.socket`.
- **GitHub:** run `gh auth login` before you push.
- **tmux:** press `prefix + I` to install the plugins.
- **GTK (`nwg-look`):** theme `Adwaita-dark`, icons `Adwaita`, font
  `Adwaita Sans 11`.
- **Qt (`qt6ct`):** style `Fusion`, colour scheme `darker`.
- **Cursor:** `Bibata-Modern-Ice` at size 24, in `nwg-look` and as
  `XCURSOR_THEME` and `XCURSOR_SIZE` in `/etc/environment`.
- **Claude Code:** install it with its own installer, not pacman.

## Packages

Each package is named after what it configures. `claude` holds the Claude Code
rules (`CLAUDE.md`), settings, skills, status line, keybindings and the
`source-guard` mod.

## Add a config

```sh
mkdir -p ~/dotfiles/foo/.config/foo
mv ~/.config/foo/foo.conf ~/dotfiles/foo/.config/foo/
```

Add `foo` to `PACKAGES` in `install.sh`, run `./install.sh`, and commit.

If the app also writes data to that folder, add the folder to the `mkdir -p`
list in `install.sh`. Otherwise Stow links the whole folder and the data lands
in the repo.

## Repair a replaced link

Some apps save by replacing the link with a plain file, such as kitty's theme
picker and Claude Code's `/config`. `./install.sh check` lists those files. To
repair one:

```sh
mv ~/.config/kitty/kitty.conf ~/dotfiles/kitty/.config/kitty/kitty.conf
./install.sh
git diff
```

## Credits

The zsh config started from
[radleylewis/zsh](https://github.com/radleylewis/zsh) (MIT). Its licence is in
`zsh/.config/zsh/LICENSE`.
