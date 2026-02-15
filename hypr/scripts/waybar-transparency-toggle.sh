#!/bin/bash

# ═════════════════════════════════════════════════
# WAYBAR TRANSPARENCY TOGGLE
# ═════════════════════════════════════════════════

CSS_FILE="$HOME/.config/waybar/style.css"
BACKUP_FILE="$HOME/.config/waybar/style.css.opaque-backup"

if [ "$1" = "--opaque" ] || [ "$1" = "--dark" ]; then
    echo "Switching Waybar to opaque (dark) background..."
    
    # Restore from backup
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$CSS_FILE"
        echo "✓ Restored opaque background from backup"
    else
        echo "✗ No backup file found. Please create one manually."
        exit 1
    fi
    
elif [ "$1" = "--transparent" ] || [ "$1" = "--light" ]; then
    echo "Switching Waybar to transparent background..."
    
    # Create backup if it doesn't exist
    if [ ! -f "$BACKUP_FILE" ]; then
        cp "$CSS_FILE" "$BACKUP_FILE"
        echo "✓ Created backup of current CSS"
    fi
    
    # Check if rule already exists
    if grep -q "window.waybar { background: transparent; }" "$CSS_FILE"; then
        echo "ℹ Waybar already has transparent background"
    else
        # Remove any existing window.waybar rule
        sed -i '/\/\* Main Waybar Bar/,/^}/d' "$CSS_FILE" 2>/dev/null
        
        # Add transparent background rule at the beginning
        sed -i '2 a\
\
/* Main Waybar Bar - Transparent background */\
window.waybar {\
    background: transparent;\
}' "$CSS_FILE"
        echo "✓ Waybar now has transparent background"
        echo "  Your wallpaper will show through (with blur)"
    fi
    
else
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --transparent, --light   Make Waybar background transparent (wallpaper shows through)"
    echo "  --opaque, --dark        Make Waybar background opaque (blocks wallpaper)"
    echo ""
    echo "Current status:"
    if grep -q "window.waybar { background: transparent; }" "$CSS_FILE"; then
        echo "  Mode: Transparent"
    else
        echo "  Mode: Opaque"
    fi
    exit 1
fi

# Restart Waybar to apply changes
killall waybar 2>/dev/null
waybar & disown

sleep 1
echo ""
echo "✓ Waybar restarted"
