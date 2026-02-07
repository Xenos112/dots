#!/usr/bin/env bash

# Theme Selector Script for Xenos Config
# Manages themes across multiple applications
THEMES_DIR="$HOME/.config/xenos/themes"
ROFI_CONFIG="$HOME/.config/rofi/styles/rofi.rasi"
NVIM_CONFIG="$HOME/.config/nvim/lua/plugins/theme.lua"
KITTY_CONFIG="$HOME/.config/kitty/kitty-theme.conf"
HYPERLAND_CONFIG="$HOME/.config/hypr/hyprland-theme.conf"
FOOT_CONFIG="$HOME/.config/foot/foot-theme.conf"
# Get list of available themes
get_themes() {
    if [[ ! -d "$THEMES_DIR" ]]; then
        echo "Error: Themes directory not found!"
        exit 1
    fi
   
    # Get unique theme names (without file extensions)
    find "$THEMES_DIR" -type d -mindepth 1 -maxdepth 1 -exec basename {} \; | sort
}
# Safe notification function
send_notification() {
    if command -v notify-send &> /dev/null && pgrep -x dunst &> /dev/null || pgrep -x mako &> /dev/null; then
        notify-send "$@" 2>/dev/null
    else
        echo "Notification: $1 - $2"
    fi
}
# Apply theme based on selection
apply_theme() {
    local theme_name="$1"
    local theme_path="$THEMES_DIR/$theme_name"
   
    if [[ ! -d "$theme_path" ]]; then
        send_notification "Theme Selector" "Theme '$theme_name' not found!" -u critical
        exit 1
    fi
   
    local applied=0
   
    # Apply Rofi theme
    if [[ -f "$theme_path/rofi.rasi" ]]; then
        cp "$theme_path/rofi.rasi" "$ROFI_CONFIG"
        echo "✓ Rofi theme applied"
        ((applied++))
    fi
   
    # Apply Neovim theme
    if [[ -f "$theme_path/nvim.lua" ]]; then
        mkdir -p "$(dirname "$NVIM_CONFIG")"
        cp "$theme_path/nvim.lua" "$NVIM_CONFIG"
        echo "✓ Neovim theme applied"
        ((applied++))
    fi
   
    # Apply Kitty theme
    if [[ -f "$theme_path/kitty-theme.conf" ]]; then
        cp "$theme_path/kitty-theme.conf" "$KITTY_CONFIG"
       
        # Reload kitty
        killall -SIGUSR1 kitty 2>/dev/null
        echo "✓ Kitty theme applied"
        ((applied++))
    fi

    # Apply Hyprland theme
    if [[ -f "$theme_path/hyprland-theme.conf" ]]; then
        cp "$theme_path/hyprland-theme.conf" "$HYPERLAND_CONFIG"
        echo "✓ Hyprland theme applied"
        ((applied++))
    fi

    # Apply Foot theme
    if [[ -f "$theme_path/foot-theme.ini" ]]; then
        cp "$theme_path/foot-theme.ini" "$FOOT_CONFIG"
        killall -SIGUSR1 foot 2>/dev/null
        echo "✓ Foot theme applied"
        ((applied++))
    fi
   
    # Apply other app configs if they exist
    if [[ -f "$theme_path/waybar-theme.css" ]] && [[ -d "$HOME/.config/waybar" ]]; then
        cp "$theme_path/waybar-theme.css" "$HOME/.config/waybar/waybar-theme.css"
        killall -SIGUSR2 waybar 2>/dev/null
        echo "✓ Waybar theme applied"
        ((applied++))
    fi
   
    if [[ -f "$theme_path/dunst.conf" ]] && [[ -d "$HOME/.config/dunst" ]]; then
        cp "$theme_path/dunst.conf" "$HOME/.config/dunst/dunstrc"
        killall dunst 2>/dev/null
        echo "✓ Dunst theme applied"
        ((applied++))
    fi
   
    # Apply random wallpaper if directory exists
    if [[ -d "$theme_path/wallpapers" ]]; then
        wallpaper=$(find "$theme_path/wallpapers" -type f -iregex '.*\.\(jpg\|jpeg\|png\|gif\)' | shuf -n 1)
        if [[ -n "$wallpaper" ]]; then
            # Set wallpaper using swww (common for Hyprland; adjust if using a different tool like hyprpaper)
            if command -v swww &> /dev/null; then
                swww img "$wallpaper"
                echo "✓ Random wallpaper applied from $theme_name"
                ((applied++))
            else
                send_notification "Theme Selector" "swww not found; wallpaper not applied" -u normal
                echo "Warning: swww not found; skipping wallpaper"
            fi
        else
            send_notification "Theme Selector" "No wallpapers found in $theme_path/wallpapers" -u normal
            echo "No wallpapers found in $theme_path/wallpapers"
        fi
    else
        echo "No wallpapers directory for $theme_name"
    fi
   
    # Save current theme
    mkdir -p "$HOME/.config/xenos"
    echo "$theme_name" > "$HOME/.config/xenos/current_theme"
   
    # Send notification
    send_notification "Theme Applied" "$theme_name theme applied to $applied applications" -u normal
}

# Get current theme
get_current_theme() {
    if [[ -f "$HOME/.config/xenos/current_theme" ]]; then
        cat "$HOME/.config/xenos/current_theme"
    else
        echo "none"
    fi
}
# Main function
main() {
    local current_theme=$(get_current_theme)
    local themes=$(get_themes)
   
    if [[ -z "$themes" ]]; then
        send_notification "Theme Selector" "No themes found in $THEMES_DIR" -u critical
        exit 1
    fi
   
    # Show rofi menu with icons
    selected=$(
        while IFS= read -r theme; do
            if [[ "$theme" == "$current_theme" ]]; then
                printf "%s\x00icon\x1f%s\n" "󰄬 $theme (current)" "$THEMES_DIR/$theme/logo.png"
            else
                printf "%s\x00icon\x1f%s\n" "󰏗 $theme" "$THEMES_DIR/$theme/logo.png"
            fi
        done <<< "$themes" | rofi -dmenu -i -p "Select Theme" -show-icons -markup-rows
    )
   
    if [[ -n "$selected" ]]; then
        # Extract theme name (remove icon and "(current)" suffix)
        theme_name=$(echo "$selected" | sed 's/^[^ ]* //' | sed 's/ (current)$//')
       
        # Apply the selected theme
        apply_theme "$theme_name"
    fi
}
# Run main function
main
