#!/usr/bin/env bash
# Hyprland + Paru + common packages installer
# 2025 version - with better UX and safety checks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ──── Helper functions ────────────────────────────────────────────────
msg_info()  { printf "${BLUE}➜${NC} %s\n" "$*"; }
msg_ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
msg_warn()  { printf "${YELLOW}⚠ %s${NC}\n" "$*"; }
msg_error() { printf "${RED}✗ ERROR:${NC} %b\n" "$*" >&2; exit 1; }

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ──── Main ─────────────────────────────────────────────────────────────

clear
cat << "EOF"
   __  __        __             __         __
  / / / /_  ____/ /_  ___  ____/ /  ____ _/ /_____
 / /_/ / / / / / __ \/ _ \/ __  /  / __ `/ //_/ _ \
/ __  / /_/ / / / / /  __/ /_/ /  / /_/ / ,< /  __/
/_/ /_/\__,_/_/_/  /\___/\__,_/   \__,_/_/|_|\___/
               /____/
           Hyprland + Paru installer
EOF
echo

# 1. Check we are on Arch / Arch-based distro
if [[ ! -f /etc/arch-release && ! -f /etc/manjaro-release ]]; then
    msg_error "This script is designed for Arch Linux / Arch-based distributions only!"
fi

# 2. Check we are not root
if [[ $EUID -eq 0 ]]; then
    msg_error "Please do NOT run this script as root!\nRun it as normal user."
fi

msg_info "Starting installation... (you will be asked for sudo password few times)"

# ──── Step 1 : Install base-devel + git if missing ─────────────────────
msg_info "Installing base-devel & git (needed for building AUR packages)..."

# base-devel is a group, so check its tools directly (group membership is not
# recorded when the packages were installed individually).
if ! command_exists gcc || ! command_exists make || ! command_exists fakeroot \
    || ! command_exists pkgconf || ! command_exists git; then
    sudo pacman -S --needed --noconfirm base-devel git || msg_error "Failed to install base-devel & git"
    msg_ok "base-devel & git installed"
else
    msg_ok "base-devel & git already installed"
fi

# ──── Step 2 : Install paru ────────────────────────────────────────────
if ! command_exists paru; then
    msg_info "Installing paru (AUR helper)..."

    PARU_DIR="$HOME/paru-bin-temp"

    rm -rf "$PARU_DIR" 2>/dev/null || true
    git clone https://aur.archlinux.org/paru-bin.git "$PARU_DIR" || msg_error "Failed to clone paru-bin"
    cd "$PARU_DIR" || msg_error "Failed to cd into paru directory"

    makepkg -si --noconfirm --needed || msg_error "Failed to build/install paru"

    cd - >/dev/null
    rm -rf "$PARU_DIR"

    if ! command_exists paru; then
        msg_error "paru installation failed - not found in PATH"
    fi

    msg_ok "paru successfully installed!"
else
    msg_ok "paru already installed → updating it..."
    paru -S --needed --noconfirm paru || msg_warn "paru update failed, continuing anyway..."
fi

# ──── Step 3 : Install all packages ────────────────────────────────────
msg_info "Installing packages... (this may take a while)"

PACKAGES=(
    # Hyprland & core
    hyprland
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    waybar
    kitty
    bibata-cursor-theme-bin
    zsh
    rofi
    zen-browser-bin
    swaync
    swayosd
    awww
    # Fonts
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
    noto-fonts-emoji
    # Utils
    brightnessctl
    zoxide
    lazygit
    grim
    slurp
    tlp
    tlp-rdw
    wl-clipboard
    cliphist
    xdg-user-dirs
    oh-my-posh-bin
    # Audio / network
    pavucontrol
    network-manager-applet
    qt5ct
    # Bluetooth
    bluez
    bluez-utils
    blueman
    # Development / modern JS/TS stack
    nodejs
    npm
    # pnpm-bin
    bun
    go
    # Rust
    rust
    github-cli
    python
    uv
    tmux
    # Search tools
    fzf
    ripgrep
    stow
    # Apps
    discord
    nautilus
    wlogout
)

msg_info "Installing ${#PACKAGES[@]} packages..."

# Split into two calls for better feedback and error isolation
paru -S --needed --noconfirm "${PACKAGES[@]}" || {
    msg_warn "Some packages failed to install"
    msg_info "Trying again without --noconfirm to see detailed errors..."
    paru -S --needed "${PACKAGES[@]}"
}

msg_ok "Package installation finished!"

# ──── Install Zsh ──────────────────────────────────────────────────────
if command_exists zsh; then
    ZSH_PATH="$(command -v zsh)"
    if [[ "$(basename "$SHELL")" == "zsh" ]]; then
        msg_ok "Zsh is already the default shell"
    else
        chsh -s "$ZSH_PATH"
        msg_ok "Default shell changed to Zsh"
    fi
else
    msg_warn "zsh not found - skipping default shell change"
fi


# ──── Enable TLP ───────────────────────────────────────────────────────
msg_info "Enabling TLP service..."
if pacman -Q power-profiles-daemon &>/dev/null; then
    msg_info "Masking power-profiles-daemon (conflicts with TLP)..."
    sudo systemctl mask --now power-profiles-daemon.service || true
fi
sudo systemctl enable --now tlp.service
msg_ok "TLP service enabled"

# ──── Install TPM ──────────────────────────────────────────────────────
msg_info "Installing TPM (Tmux Plugin Manager)..."
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    msg_ok "TPM installed"
else
    msg_ok "TPM already installed"
fi

# ──── Install Tmux Sessionizer ──────────────────────────────────────────────────────
msg_info "Installing Tmux Sessionizer..."
mkdir -p "$HOME/.local/bin"
install -m 755 "$SCRIPT_DIR/tmux-sessionizer" "$HOME/.local/bin/tmux-sessionizer"
msg_ok "Tmux Sessionizer installed"

# ──── Stow dotfiles ────────────────────────────────────────────────────
msg_info "Stowing dotfiles..."

cd "$SCRIPT_DIR" || msg_error "Failed to cd into dotfiles directory"

if ! command_exists stow; then
    msg_error "stow is not installed - cannot stow dotfiles"
fi

# .stowrc handles the target ($HOME) and ignored files
stow_packages=(
    hypr
    kitty
    nvim
    oh-my-posh
    rofi
    swaync
    swayosd
    waybar
    wlogout
    xenos
    zsh
    tmux
)

# Existing real files make stow abort, so move them aside first.
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

backup_conflicts() {
    local package="$1" entry target
    while IFS= read -r -d '' entry; do
        target="$HOME/${entry#./}"
        if [[ -e "$target" && ! -L "$target" ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "${entry#./}")"
            mv "$target" "$BACKUP_DIR/${entry#./}"
            msg_warn "Backed up existing ${entry#./} → $BACKUP_DIR"
        fi
    done < <(cd "$package" && find . \( -type f -o -type l \) -print0)
}

stow_failed=()
for package in "${stow_packages[@]}"; do
    if [[ ! -d "$package" ]]; then
        msg_warn "Skipping missing package: $package"
        continue
    fi

    backup_conflicts "$package"

    if stow --restow "$package"; then
        msg_ok "Stowed $package"
    else
        msg_warn "Failed to stow $package"
        stow_failed+=("$package")
    fi
done

if ((${#stow_failed[@]})); then
    msg_warn "Some packages failed to stow: ${stow_failed[*]}"
else
    msg_ok "Dotfiles stowed successfully"
fi

# ──── Apply the current theme ──────────────────────────────────────────
# Theme colors are generated files (not stowed), so they must exist before
# the first login. Keep the existing choice when reinstalling.
THEME="catppuccin-mocha"
if [[ -f "$HOME/.local/state/xenos/current_theme" ]]; then
    THEME=$(<"$HOME/.local/state/xenos/current_theme")
elif [[ -f "$HOME/.config/xenos/current_theme" ]]; then
    THEME=$(<"$HOME/.config/xenos/current_theme")
fi

msg_info "Applying theme: $THEME"
if "$HOME/.config/xenos/theme.sh" apply "$THEME"; then
    msg_ok "Theme applied"
else
    msg_warn "Could not apply theme '$THEME' - run ~/.config/xenos/theme.sh manually"
fi

# ──── Final messages ───────────────────────────────────────────────────
echo
msg_ok "Installation completed! 🎉"
if [[ -d "$BACKUP_DIR" ]]; then
    msg_warn "Previous dotfiles were backed up to $BACKUP_DIR"
fi
echo -e "${CYAN}Next recommended steps:${NC}"
echo "  1. Reboot your system"
echo "  2. Select Hyprland session at login screen"
echo "  3. Edit ~/.config/hypr/hyprland.lua"
echo
echo -e "Useful commands:"
echo "  paru -Syu                    → update system + AUR"
echo "  paru -Rns package            → remove package + unneeded deps"
echo "  ~/.config/xenos/theme.sh     → switch the color theme"
echo "  ~/.config/xenos/wallpaper.sh → pick a wallpaper"
echo

exit 0
