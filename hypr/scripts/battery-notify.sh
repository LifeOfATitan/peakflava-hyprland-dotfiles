#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# BATTERY NOTIFICATION SCRIPT
# ═══════════════════════════════════════════════════════════════════

last_status=""
low_notified=false
critical_notified=false

while true; do
    # Get battery info
    # Using /sys/class/power_supply/ for reliability
    battery_status=$(cat /sys/class/power_supply/BAT0/status)
    battery_level=$(cat /sys/class/power_supply/BAT0/capacity)

    # Charging notification
    if [ "$battery_status" = "Charging" ] && [ "$last_status" != "Charging" ]; then
        notify-send -i battery-charging "Battery Charging" "Power cable connected: ${battery_level}%"
        low_notified=false
        critical_notified=false
    fi

    # Discharging notification
    if [ "$battery_status" = "Discharging" ] && [ "$last_status" != "Discharging" ]; then
        notify-send -i battery-discharging "Battery Discharging" "Power cable disconnected: ${battery_level}%"
    fi

    # Low battery (15%)
    if [ "$battery_status" = "Discharging" ] && [ "$battery_level" -le 15 ] && [ "$low_notified" = false ]; then
        notify-send -u normal -i battery-low "Battery Low" "Battery level is at ${battery_level}%"
        low_notified=true
    fi

    # Critical battery (5%)
    if [ "$battery_status" = "Discharging" ] && [ "$battery_level" -le 5 ] && [ "$critical_notified" = false ]; then
        notify-send -u critical -i battery-caution "Battery Critical" "Battery level is at ${battery_level}%! Plug in now!"
        critical_notified=true
    fi

    # Reset flags if battery is charged above thresholds
    if [ "$battery_level" -gt 15 ]; then
        low_notified=false
    fi
    if [ "$battery_level" -gt 5 ]; then
        critical_notified=false
    fi

    last_status="$battery_status"
    sleep 60 # Check every minute
done
