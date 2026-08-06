#!/usr/bin/env bash

batt="/sys/class/power_supply/BAT0"
low=15
critical=5
notified=""

while true; do
    cap=$(cat "$batt/capacity" 2>/dev/null)
    status=$(cat "$batt/status" 2>/dev/null)

    if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
        notified=""
    elif [[ "$cap" -le "$critical" && "$notified" != "critical" ]]; then
        notify-send -u critical -t 0 "Battery Critical" "Battery at ${cap}% - plug in now"
        notified="critical"
    elif [[ "$cap" -le "$low" && "$notified" != "low" ]]; then
        notify-send -u critical -t 0 "Battery Low" "Battery at ${cap}% - consider plugging in"
        notified="low"
    fi

    sleep 60
done
