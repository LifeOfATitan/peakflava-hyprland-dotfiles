#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# SWWW WALLPAPER SWITCHER SCRIPT
# ═══════════════════════════════════════════════════════════════════

WALLPAPER_DIR="$HOME/wallpapers"
INTERVAL=7200 # 2 hours in seconds

# Initialize swww if not running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

# Function to change wallpaper
change_wallpaper() {
    if [ -d "$WALLPAPER_DIR" ]; then
        # Get a random wallpaper from the directory
        wallpaper=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | shuf -n 1)
        
        if [ -n "$wallpaper" ]; then
            # Apply wallpaper with a nice transition
            swww img "$wallpaper" --transition-type random --transition-step 1 --transition-fps 60
            # notify-send -i image "Wallpaper Changed" "New wallpaper: $(basename "$wallpaper")"
        fi
    fi
}

# If script is called with "manual" argument, just change once and exit
if [ "$1" = "manual" ]; then
    change_wallpaper
    exit 0
fi

# Main loop for automatic switching
while true; do
    change_wallpaper
    sleep "$INTERVAL"
done
