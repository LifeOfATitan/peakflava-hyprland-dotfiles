#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# SMART SCREENSHOT TOOL
# Handles Auto-Save, "Save As", and Clipboard copying
# ═══════════════════════════════════════════════════════════════════

# Paths
DEFAULT_DIR="$HOME/Pictures/Screenshots"
CACHE_DIR_FILE="$HOME/.cache/screenshot_last_dir"
TEMP_IMG="/tmp/screenshot_$(date +%s).png"

# Ensure default directory exists
mkdir -p "$DEFAULT_DIR"

# Sound effect (can be disabled)
play_sound() {
    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga 2>/dev/null &
    fi
}

# Notification function
notify_user() {
    local filepath="$1"
    
    if [ "$filepath" = "clipboard" ]; then
        notify-send "Screenshot Taken" "Copied to clipboard only"
    else
        notify-send -i "$filepath" "Screenshot Taken" "Saved to: $filepath\n(Copied to clipboard)"
    fi
    play_sound
}

# Core capture logic
capture() {
    local mode="$1"
    
    case "$mode" in
        "full")
            grim "$TEMP_IMG"
            ;;
        "area"|"save-as"|"copy")
            grim -g "$(slurp)" "$TEMP_IMG"
            ;;
    esac
    
    # Check if capture was successful (user might have pressed ESC in slurp)
    if [ ! -f "$TEMP_IMG" ]; then
        exit 1
    fi
}

# Main Logic
MODE="$1"

# 1. Capture first (don't lose the moment)
capture "$MODE"

# 2. Copy to clipboard immediately
wl-copy < "$TEMP_IMG"

# 3. Handle Saving
if [ "$MODE" == "save-as" ]; then
    # Get last used directory
    if [ -f "$CACHE_DIR_FILE" ]; then
        LAST_DIR=$(cat "$CACHE_DIR_FILE")
    else
        LAST_DIR="$HOME/Pictures"
    fi
    
    # Ensure last dir actually exists, fallback if not
    [ ! -d "$LAST_DIR" ] && LAST_DIR="$HOME/Pictures"
    
    # Generate filename
    FILENAME="Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
    
    # Open Zenity dialog
    SAVE_PATH=$(zenity --file-selection --save --confirm-overwrite \
                --filename="$LAST_DIR/$FILENAME" \
                --title="Save Screenshot As..." \
                --file-filter="PNG Images | *.png")
                
    if [ -n "$SAVE_PATH" ]; then
        # Ensure it has .png extension
        if [[ "$SAVE_PATH" != *.png ]]; then
            SAVE_PATH="${SAVE_PATH}.png"
        fi
        
        # Move file
        mv "$TEMP_IMG" "$SAVE_PATH"
        
        # Update cache with the DIRECTORY of the saved file
        dirname "$SAVE_PATH" > "$CACHE_DIR_FILE"
        
        notify_user "$SAVE_PATH"
    else
        # User cancelled dialog, but image is in clipboard/tmp
        # Let's save to default folder as backup so they don't lose it
        FINAL_PATH="$DEFAULT_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
        mv "$TEMP_IMG" "$FINAL_PATH"
        notify-send "Screenshot Saved" "Dialog cancelled. Saved to default folder:\n$FINAL_PATH"
    fi

elif [ "$MODE" == "copy" ]; then
    # Copy only - cleanup temp file and notify
    rm -f "$TEMP_IMG"
    notify_user "clipboard"

else
    # Default Quick Save
    FINAL_PATH="$DEFAULT_DIR/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
    mv "$TEMP_IMG" "$FINAL_PATH"
    notify_user "$FINAL_PATH"
fi
