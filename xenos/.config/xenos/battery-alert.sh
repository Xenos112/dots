#!/usr/bin/env bash

# Low battery notifications. Started from Hyprland; flock keeps a single
# instance around when the compositor is restarted.

set -uo pipefail

# Use the first battery instead of assuming BAT0.
batt=""
for candidate in /sys/class/power_supply/BAT*; do
    if [[ -d "$candidate" ]]; then
        batt="$candidate"
        break
    fi
done
[[ -n "$batt" ]] || exit 0

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/battery-alert.lock"
flock -n 9 || exit 0

low=15
critical=5
notified=""

while true; do
    cap=$(cat "$batt/capacity" 2>/dev/null || true)
    status=$(cat "$batt/status" 2>/dev/null || true)

    # Capacity can disappear while a battery is being swapped or reset.
    if [[ -z "$cap" ]]; then
        sleep 60
        continue
    fi

    if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
        notified=""
    elif ((cap <= critical)) && [[ "$notified" != "critical" ]]; then
        notify-send -u critical -t 0 "Battery Critical" "Battery at ${cap}% - plug in now"
        notified="critical"
    elif ((cap <= low)) && [[ "$notified" != "low" ]]; then
        notify-send -u critical -t 0 "Battery Low" "Battery at ${cap}% - consider plugging in"
        notified="low"
    fi

    sleep 60
done
