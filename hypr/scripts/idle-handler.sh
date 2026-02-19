#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# SMART IDLE HANDLER
# Handles power states differently for Battery vs AC
# ═══════════════════════════════════════════════════════════════════

# Actions: dim, undim, lock, suspend
# Modes: battery, ac, any

ACTION=$1
MODE=$2

# Check power state (1 = AC plugged in, 0 = Battery)
# Note: Adapting to your system's path found earlier (ADP0)
IS_PLUGGED_IN=$(cat /sys/class/power_supply/ADP0/online)

# Function to dim screen
dim_screen() {
    # Only dim if not already dimmed (to avoid saving a dimmed value)
    if [ ! -f /tmp/hypr_brightness_dimmed ]; then
        # Save current brightness
        brightnessctl g > /tmp/hypr_brightness_val
        touch /tmp/hypr_brightness_dimmed
        # Set to minimum
        brightnessctl -s set 10
    fi
}

# Function to restore screen
undim_screen() {
    if [ -f /tmp/hypr_brightness_dimmed ]; then
        # Restore original brightness
        brightnessctl -r
        rm -f /tmp/hypr_brightness_dimmed
        rm -f /tmp/hypr_brightness_val
    fi
}

# ═══════════════════════════════════════════════════════════════════
# LOGIC CONTROLLER
# ═══════════════════════════════════════════════════════════════════

case "$ACTION" in
    "dim")
        if [ "$MODE" == "battery" ] && [ "$IS_PLUGGED_IN" -eq 0 ]; then
            dim_screen
        elif [ "$MODE" == "ac" ] && [ "$IS_PLUGGED_IN" -eq 1 ]; then
            dim_screen
        fi
        ;;
        
    "undim")
        # Always allow undimming regardless of mode
        undim_screen
        ;;
        
    "lock")
        if [ "$MODE" == "battery" ] && [ "$IS_PLUGGED_IN" -eq 0 ]; then
            loginctl lock-session
        elif [ "$MODE" == "ac" ] && [ "$IS_PLUGGED_IN" -eq 1 ]; then
            loginctl lock-session
        elif [ "$MODE" == "any" ]; then
            loginctl lock-session
        fi
        ;;
        
    "suspend")
        if [ "$MODE" == "battery" ] && [ "$IS_PLUGGED_IN" -eq 0 ]; then
            systemctl suspend
        fi
        ;;
esac
