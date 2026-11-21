#!/usr/bin/env bash

# Store clipboard history with cliphist. Started once from Hyprland; the lock
# keeps a second watcher from spawning when the compositor restarts.

set -uo pipefail

command -v cliphist >/dev/null 2>&1 || exit 0
command -v wl-paste >/dev/null 2>&1 || exit 0

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/cliphist-watch.lock"
flock -n 9 || exit 0

wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
wait
