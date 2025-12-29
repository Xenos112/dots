#!/usr/bin/env bash
# Hyprland + Yay + common packages installer
# 2025 version - with better UX and safety checks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ──── Helper functions ────────────────────────────────────────────────
msg_info()  { printf "${BLUE}➜${NC} %s\n" "$*"; }
msg_ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
msg_warn()  { printf "${YELLOW}⚠ %s${NC}\n" "$*"; }
msg_error() { printf "${RED}✗ ERROR:${NC} %s\n" "$*" >&2; exit 1; }

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ──── Main ─────────────────────────────────────────────────────────────

clear
cat << "EOF"
   __  __        __             __         __
  / / / /_  ____/ /_  ___  ____/ /  ____ _/ /_____
 / /_/ / / / / / __ \/ _ \/ __  /  / __ `/ //_/ _ \
/ __  / /_/ / / / / /  __/ /_/ /  / /_/ / ,< /  __/
/_/ /_/\__,_/_/_/  /\___/\__,_/   \__,_/_/|_|\___/
               /____/
           Hyprland + Yay installer
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

if ! pacman -Q base-devel git &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git || msg_error "Failed to install base-devel & git"
    msg_ok "base-devel & git installed"
else
    msg_ok "base-devel & git already installed"
fi

# ──── Step 2 : Install yay ─────────────────────────────────────────────
if ! command_exists yay; then
    msg_info "Installing yay (AUR helper)..."

    YAY_DIR="$HOME/yay-bin-temp"

    rm -rf "$YAY_DIR" 2>/dev/null || true
    git clone https://aur.archlinux.org/yay-bin.git "$YAY_DIR" || msg_error "Failed to clone yay-bin"
    cd "$YAY_DIR" || msg_error "Failed to cd into yay directory"

    makepkg -si --noconfirm --needed || msg_error "Failed to build/install yay"

    cd - >/dev/null
    rm -rf "$YAY_DIR"

    if ! command_exists yay; then
        msg_error "yay installation failed - not found in PATH"
    fi

    msg_ok "yay successfully installed!"
else
    msg_ok "yay already installed → updating it..."
    yay -Syu --noconfirm yay || msg_warn "yay update failed, continuing anyway..."
fi

# ──── Step 3 : Install all packages ────────────────────────────────────
msg_info "Installing packages... (this may take a while)"

PACKAGES=(
    # Hyprland & core
    hyprland
    waybar
    swww
    kitty
    bibata-cursor-theme-bin
    # Fonts
    noto-fonts
    noto-fonts-emoji
    ttf-ms-fonts
    # Utils
    brightnessctl
    zoxide
    lazygit
    # Bluetooth
    bluez
    bluez-utils
    blueman
    # Development / modern JS/TS stack
    nodejs
    npm
    pnpm-bin
    bun-bin
    go
    github-cli
    # Search tools
    repgrep
)

msg_info "Installing ${#PACKAGES[@]} packages..."

# Split into two calls for better feedback and error isolation
yay -S --needed --noconfirm "${PACKAGES[@]}" || {
    msg_warn "Some packages failed to install"
    msg_info "Trying again without --noconfirm to see detailed errors..."
    yay -S --needed "${PACKAGES[@]}"
}

msg_ok "Package installation finished!"

# ──── Final messages ───────────────────────────────────────────────────
echo
msg_ok "Installation completed! 🎉"
echo -e "${CYAN}Next recommended steps:${NC}"
echo "  1. Reboot your system"
echo "  2. Select Hyprland session at login screen"
echo "  3. Configure ~/.config/hypr/hyprland.conf"
echo
echo -e "Useful commands:"
echo "  yay -Syu          → update system + AUR"
echo "  yay -Rns package  → remove package + unneeded deps"
echo "  zoxide init       → don't forget to add to your shell config!"
echo

exit 0
