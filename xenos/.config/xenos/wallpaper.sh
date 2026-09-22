#!/usr/bin/env bash

# Wallpaper picker - one horizontal row, images at full height, cover-cropped by width.
THEMES_DIR="$HOME/.config/xenos/themes"
ROFI_DIR="$HOME/.config/rofi"

# kill any stale rofi instance first (rofi locks prevent new windows)
if pidof rofi >/dev/null; then
    pkill rofi
    sleep 0.2
fi

CUR_THEME=$(cat "$HOME/.config/xenos/current_theme" 2>/dev/null)
[[ -z "$CUR_THEME" ]] && CUR_THEME="flexok"
WALLPAPER_DIR="$THEMES_DIR/$CUR_THEME/wallpapers"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Wallpaper" "No wallpapers for theme '$CUR_THEME'" -u critical
    exit 1
fi

mapfile -d '' wallpapers < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0 | sort -z)
count=${#wallpapers[@]}
if [[ "$count" -eq 0 ]]; then
    notify-send "Wallpaper" "No wallpapers found for '$CUR_THEME'" -u critical
    exit 1
fi

# generate the picker theme: base design + file-level overrides only
theme="$ROFI_DIR/wallpaper-picker.rasi"
tmp_theme=$(mktemp /tmp/wallpaper-picker-XXXXXX.rasi)
cat > "$tmp_theme" <<EOF
@import "$theme"

listview {
    columns: $count;
}
EOF

selected=$(
    for wp in "${wallpapers[@]}"; do
        printf "%s\x00icon\x1f%s\n" "$(basename "$wp")" "$wp"
    done | rofi -dmenu -i -show-icons -theme "$tmp_theme"
)
rm -f "$tmp_theme"

if [[ -n "$selected" ]]; then
    selected="$WALLPAPER_DIR/$selected"
    if command -v awww &> /dev/null; then
        awww img "$selected"
        notify-send "Wallpaper" "$(basename "$selected")" -u normal
    else
        notify-send "Wallpaper" "awww not found; wallpaper not applied" -u critical
    fi
fi
