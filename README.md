# dots

My personal Hyprland setup for Arch Linux. Everything lives in this repo and is
symlinked into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/).

It is not a framework and it is not meant to be installed on top of an existing
desktop. `install.sh` assumes a fairly clean Arch install (the one `archinstall`
gives you is fine), pulls in the packages it needs and stows the configs.

## Install

```bash
git clone https://github.com/Xenos112/dots ~/dots
cd ~/dots
./install.sh
```

The script installs `paru` if you don't have an AUR helper, installs the package
list, stows the configs and applies the default theme. Reboot afterwards and pick
the Hyprland session at the login screen.

If you already have files in the way, they are moved to
`~/.dotfiles-backup-<date>` before stowing, so nothing is overwritten silently.

## Layout

Each top-level directory is a stow package:

| Directory | Goes to |
| --- | --- |
| `hypr` | `~/.config/hypr` (Hyprland, hyprlock, hypridle) |
| `kitty` | `~/.config/kitty` |
| `nvim` | `~/.config/nvim` |
| `oh-my-posh` | `~/.config/oh-my-posh` |
| `rofi` | `~/.config/rofi` |
| `swaync` | `~/.config/swaync` |
| `swayosd` | `~/.config/swayosd` |
| `tmux` | `~/.tmux.conf` |
| `waybar` | `~/.config/waybar` |
| `wlogout` | `~/.config/wlogout` |
| `xenos` | `~/.config/xenos` (theme switcher and helper scripts) |
| `zsh` | `~/.zshrc` |

`tmux-sessionizer` is a standalone script; `install.sh` copies it to
`~/.local/bin`.

## Keybinds

`SUPER` is the main modifier.

| Key | Action |
| --- | --- |
| `SUPER + Return` | Terminal (kitty) |
| `SUPER + R` | Application launcher (rofi) |
| `SUPER + E` | File manager (nautilus) |
| `SUPER + B` | Browser (zen) |
| `SUPER + Q` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + J` | Toggle split direction |
| `SUPER + 1..0` | Switch workspace |
| `SUPER + SHIFT + 1..0` | Move window to workspace |
| `SUPER + S` | Toggle special workspace |
| `SUPER + L` | Lock screen |
| `SUPER + SHIFT + V` | Clipboard history |
| `SUPER + SHIFT + Q` | Logout menu |
| `SUPER + T` | Theme picker |
| `SUPER + SHIFT + T` | Wallpaper picker |
| `Print` | Screenshot a region |
| `SHIFT + Print` | Screenshot the whole screen |

Media keys go through `swayosd` and `playerctl`.

## Themes

`xenos` is the theme system. Each theme in `~/.config/xenos/themes` holds the
colors and wallpapers for one look (hyprland, kitty, neovim, rofi, swaync,
waybar). `theme.sh` applies one:

```bash
~/.config/xenos/theme.sh          # pick with rofi
~/.config/xenos/theme.sh list     # show available themes
~/.config/xenos/theme.sh apply rose-pine
```

The generated color files (for example `~/.config/hypr/hyprland-theme.lua`) are
deliberately not tracked in git. They are written as real files next to the
stow symlinks, which is why stow runs with `--no-folding`. Your current theme is
stored in `~/.local/state/xenos/current_theme`.

Wallpapers are set with `awww`. `wallpaper.sh` picks one from the active theme.

## Notes

- Neovim installs its language servers through `mason`, not through pacman. The
  Rust toolchain itself (`rustc`, `cargo`, `rustfmt`, `clippy`) comes from the
  `rust` package.
- `nvim/lazy-lock.json` is committed so plugin versions stay reproducible.
- Machine-specific Hyprland settings belong in `~/.config/hypr/local.lua`, which
  is ignored by git and loaded if present.
- The wallpaper images in `xenos/themes/*/wallpapers` are part of the repo on
  purpose.
