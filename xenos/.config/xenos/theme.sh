#!/usr/bin/env bash

# Theme selector for the Xenos config.
# Applies a theme across Hyprland, kitty, Neovim, rofi, waybar, swaync and foot.
#
# Usage:
#   theme.sh                 pick a theme with rofi
#   theme.sh apply <theme>   apply a theme directly (used by install.sh)
#   theme.sh list            list available themes

set -uo pipefail

# Generated files must be real files. With a folded stow layout (~/.config/hypr
# being a symlink into the repo) writing them would modify the dotfiles repo.
for dir in "$HOME/.config/hypr" "$HOME/.config/kitty" "$HOME/.config/nvim" \
    "$HOME/.config/rofi" "$HOME/.config/waybar" "$HOME/.config/swaync"; do
    if [[ -L "$dir" ]]; then
        echo "Warning: $dir is a folded stow symlink." >&2
        echo "Run install.sh (or 'stow --restow <package>' in the dots repo) first." >&2
        break
    fi
done

THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xenos/themes"
ROFI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/xenos"
CURRENT_THEME_FILE="$STATE_DIR/current_theme"

ROFI_THEME="$ROFI_DIR/styles/rofi.rasi"
NVIM_THEME="$HOME/.config/nvim/lua/plugins/theme.lua"
KITTY_THEME="$HOME/.config/kitty/kitty-theme.conf"
HYPR_THEME="$HOME/.config/hypr/hyprland-theme.lua"
FOOT_THEME="$HOME/.config/foot/foot-theme.conf"
WAYBAR_THEME="$HOME/.config/waybar/waybar-theme.css"
SWAYNC_DIR="$HOME/.config/swaync"
SWAYNC_STYLE="$SWAYNC_DIR/style.css"
SWAYNC_TEMPLATE="$SWAYNC_DIR/style.css.template"

# Themes are generated files: never copy through a symlink.
write_file() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    rm -f "$dest"
    cp "$src" "$dest"
}

get_themes() {
    if [[ ! -d "$THEMES_DIR" ]]; then
        echo "Error: Themes directory not found!" >&2
        return 1
    fi

    find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}

get_current_theme() {
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        cat "$CURRENT_THEME_FILE"
    elif [[ -f "$HOME/.config/xenos/current_theme" ]]; then
        # Legacy location, migrated on the next apply.
        cat "$HOME/.config/xenos/current_theme"
    else
        echo "none"
    fi
}

send_notification() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$@" 2>/dev/null || true
    else
        printf '%s\n' "$*"
    fi
}

# swaync only accepts plain CSS, so style.css is regenerated from a tracked
# template where the palette names are replaced with the theme's colors.
apply_swaync_theme() {
    local theme_path="$1"
    [[ -f "$SWAYNC_TEMPLATE" ]] || return 1

    local palette="$theme_path/swaync-theme.css"
    [[ -f "$palette" ]] || palette="$theme_path/waybar-theme.css"
    [[ -f "$palette" ]] || return 1

    local css name value
    css=$(<"$SWAYNC_TEMPLATE")
    while read -r name value; do
        [[ -n "$name" ]] || continue
        css=${css//"@${name}@"/$value}
    done < <(sed -n 's/^@define-color \([A-Za-z0-9_]*\)[[:space:]]*\(.*\);$/\1 \2/p' "$palette")

    mkdir -p "$SWAYNC_DIR"
    rm -f "$SWAYNC_STYLE"
    printf '%s\n' "$css" > "$SWAYNC_STYLE"

    pkill -x swaync 2>/dev/null
    setsid swaync >/dev/null 2>&1 &
    return 0
}

apply_wallpaper() {
    local theme_path="$1"

    [[ -d "$theme_path/wallpapers" ]] || return 0

    local wallpaper
    wallpaper=$(find "$theme_path/wallpapers" \( -type f -o -type l \) -iregex '.*\.\(jpg\|jpeg\|png\|gif\)' | shuf -n 1)
    if [[ -z "$wallpaper" ]]; then
        echo "No wallpapers found in $theme_path/wallpapers"
        return 0
    fi

    if ! command -v awww >/dev/null 2>&1; then
        send_notification "Theme Selector" "awww not found; wallpaper not applied" -u normal
        echo "Warning: awww not found; skipping wallpaper"
        return 0
    fi

    if ! pgrep -x awww-daemon >/dev/null 2>&1; then
        setsid awww-daemon >/dev/null 2>&1 &
        sleep 0.3
    fi

    awww img "$wallpaper" && echo "✓ Random wallpaper applied from $(basename "$theme_path")"
}

apply_theme() {
    local theme_name="$1"
    local theme_path="$THEMES_DIR/$theme_name"

    if [[ ! -d "$theme_path" ]]; then
        send_notification "Theme Selector" "Theme '$theme_name' not found!" -u critical
        return 1
    fi

    local applied=0

    if [[ -f "$theme_path/rofi.rasi" ]]; then
        write_file "$theme_path/rofi.rasi" "$ROFI_THEME"
        echo "✓ Rofi theme applied"
        applied=$((applied + 1))
    fi

    if [[ -f "$theme_path/nvim.lua" ]]; then
        write_file "$theme_path/nvim.lua" "$NVIM_THEME"
        echo "✓ Neovim theme applied"
        applied=$((applied + 1))
    fi

    if [[ -f "$theme_path/kitty-theme.conf" ]]; then
        write_file "$theme_path/kitty-theme.conf" "$KITTY_THEME"
        pkill -SIGUSR1 -x kitty 2>/dev/null
        echo "✓ Kitty theme applied"
        applied=$((applied + 1))
    fi

    if [[ -f "$theme_path/hyprland-theme.lua" ]]; then
        write_file "$theme_path/hyprland-theme.lua" "$HYPR_THEME"
        if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
            hyprctl reload >/dev/null 2>&1
        fi
        echo "✓ Hyprland theme applied"
        applied=$((applied + 1))
    fi

    if [[ -f "$theme_path/foot-theme.ini" ]]; then
        write_file "$theme_path/foot-theme.ini" "$FOOT_THEME"
        pkill -SIGUSR1 -x foot 2>/dev/null
        echo "✓ Foot theme applied"
        applied=$((applied + 1))
    fi

    if [[ -f "$theme_path/waybar-theme.css" ]] && [[ -d "$HOME/.config/waybar" ]]; then
        write_file "$theme_path/waybar-theme.css" "$WAYBAR_THEME"
        pkill -SIGUSR2 -x waybar 2>/dev/null
        echo "✓ Waybar theme applied"
        applied=$((applied + 1))
    fi

    # EWW theme (converts waybar-theme.css @define-color to SCSS vars)
    if [[ -f "$theme_path/waybar-theme.css" ]] && [[ -d "$HOME/.config/eww" ]]; then
        {
            echo "// Generated by theme.sh - do not edit"
            sed -n 's/^@define-color \([a-z0-9_]*\)[[:space:]]*\(.*\);$/$\1: \2;/p' "$theme_path/waybar-theme.css"
        } > "$HOME/.config/eww/colors.scss"
        if command -v eww &>/dev/null && eww ping &>/dev/null; then
            eww reload 2>/dev/null
        fi
        echo "✓ EWW theme applied"
        applied=$((applied + 1))
    fi

    if apply_swaync_theme "$theme_path"; then
        echo "✓ SwayNC theme applied"
        applied=$((applied + 1))
    fi

    if [[ -f "$theme_path/dunst.conf" ]] && [[ -d "$HOME/.config/dunst" ]]; then
        write_file "$theme_path/dunst.conf" "$HOME/.config/dunst/dunstrc"
        pkill -x dunst 2>/dev/null
        echo "✓ Dunst theme applied"
        applied=$((applied + 1))
    fi

    apply_wallpaper "$theme_path"

    mkdir -p "$STATE_DIR"
    echo "$theme_name" > "$CURRENT_THEME_FILE"
    rm -f "$HOME/.config/xenos/current_theme"

    send_notification "Theme Applied" "$theme_name theme applied to $applied applications" -u normal
}

pick_theme() {
    local current_theme themes selected
    current_theme=$(get_current_theme)
    themes=$(get_themes) || exit 1

    if [[ -z "$themes" ]]; then
        send_notification "Theme Selector" "No themes found in $THEMES_DIR" -u critical
        exit 1
    fi

    selected=$(
        while IFS= read -r theme; do
            printf "%s\x00icon\x1f%s\n" "$theme" "$THEMES_DIR/$theme/logo.png"
        done <<< "$themes" | rofi -dmenu -i -p "" -show-icons -theme "$ROFI_DIR/themes.rasi"
    )

    if [[ -n "$selected" ]]; then
        apply_theme "$selected"
    fi
}

case "${1:-}" in
    apply)
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 apply <theme>" >&2
            exit 1
        fi
        apply_theme "$2"
        ;;
    list)
        get_themes
        ;;
    "" | pick)
        pick_theme
        ;;
    -h | --help)
        sed -n '3,9p' "$0" | sed 's/^# \{0,1\}//'
        ;;
    *)
        echo "Unknown command: $1" >&2
        echo "Usage: $0 [apply <theme> | list]" >&2
        exit 1
        ;;
esac
