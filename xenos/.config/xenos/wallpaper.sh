#!/usr/bin/env bash

# Wallpaper Selector Script for Xenos Config
# Fetches and displays wallpapers from current theme in Rofi
THEMES_DIR="$HOME/.config/xenos/themes"
# Safe notification function
send_notification() {
    if command -v notify-send &> /dev/null && pgrep -x dunst &> /dev/null || pgrep -x mako &> /dev/null; then
        notify-send "$@" 2>/dev/null
    else
        echo "Notification: $1 - $2"
    fi
}
# Get current theme
get_current_theme() {
    if [[ -f "$HOME/.config/xenos/current_theme" ]]; then
        cat "$HOME/.config/xenos/current_theme"
    else
        echo "none"
    fi
}
# Apply wallpaper with random transition
apply_wallpaper() {
    local wallpaper_path="$1"
    if [[ -f "$wallpaper_path" ]]; then
        if command -v swww &> /dev/null; then
            # List of available transition types
            transitions=("none" "simple" "left" "right" "top" "bottom" "wipe" "wave" "grow" "center" "any" "outer")
            # Pick a random transition
            random_transition=${transitions[$((RANDOM % ${#transitions[@]}))]}
            swww img --transition-type "$random_transition" "$wallpaper_path"
            send_notification "Wallpaper Applied" "Selected wallpaper applied with $random_transition transition" -u normal
            echo "✓ Wallpaper applied: $wallpaper_path with $random_transition transition"
        else
            send_notification "Wallpaper Selector" "swww not found; wallpaper not applied" -u critical
            echo "Warning: swww not found; skipping wallpaper"
        fi
    else
        send_notification "Wallpaper Selector" "Wallpaper file not found!" -u critical
        exit 1
    fi
}
# Main function
main() {
    local current_theme=$(get_current_theme)
    if [[ "$current_theme" == "none" ]]; then
        send_notification "Wallpaper Selector" "No current theme set!" -u critical
        exit 1
    fi
   
    local theme_path="$THEMES_DIR/$current_theme"
    if [[ ! -d "$theme_path/wallpapers" ]]; then
        send_notification "Wallpaper Selector" "Wallpapers directory not found for theme '$current_theme'!" -u critical
        exit 1
    fi
   
    # Get list of wallpapers
    local wallpapers=$(find "$theme_path/wallpapers" -type f -iregex '.*\.\(jpg\|jpeg\|png\|gif\)' | sort)
   
    if [[ -z "$wallpapers" ]]; then
        send_notification "Wallpaper Selector" "No wallpapers found in $theme_path/wallpapers" -u critical
        exit 1
    fi
   
    # Show rofi menu with wallpaper thumbnails as icons
    selected=$(
        while IFS= read -r wallpaper; do
            basename=$(basename "$wallpaper")
            printf "%s\x00icon\x1f%s\n" "$basename" "$wallpaper"
        done <<< "$wallpapers" | rofi -dmenu -i -p "Select Wallpaper" -show-icons -markup-rows
    )
   
    if [[ -n "$selected" ]]; then
        # Find the full path based on selected basename
        local selected_path=$(find "$theme_path/wallpapers" -type f -name "$selected" -print -quit)
        if [[ -n "$selected_path" ]]; then
            apply_wallpaper "$selected_path"
        else
            send_notification "Wallpaper Selector" "Selected wallpaper not found!" -u critical
        fi
    fi
}
# Run main function
main
