#!/usr/bin/env bash

# Screenshot helper: saves the shot and copies it to the clipboard.
# Usage: screenshot.sh [region|full]

set -euo pipefail

mode="${1:-region}"
pictures="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$pictures"

file="$pictures/Screenshot-$(date +%F_%T).png"

case "$mode" in
    region) grim -g "$(slurp)" "$file" ;;
    full) grim "$file" ;;
    *)
        echo "usage: $0 [region|full]" >&2
        exit 1
        ;;
esac

if command -v wl-copy >/dev/null 2>&1; then
    wl-copy < "$file"
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot" "Saved $(basename "$file")" -t 1500
fi
