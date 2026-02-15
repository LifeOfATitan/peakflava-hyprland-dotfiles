#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# NOTIFICATION TRAY SCRIPT FOR WAYBAR
# ═══════════════════════════════════════════════════════════════════

NOTIFICATION_CACHE="$HOME/.cache/dunst_notifications"
DND_STATE="$HOME/.cache/dunst_dnd"
MAX_NOTIFICATIONS=50

# Initialize cache files if they don't exist
[ ! -f "$NOTIFICATION_CACHE" ] && echo "" > "$NOTIFICATION_CACHE"
[ ! -f "$DND_STATE" ] && echo "disabled" > "$DND_STATE"

case $1 in
    "show")
        # Show notifications from Dunst history instead of custom cache
        dnd_status=$(cat "$DND_STATE" 2>/dev/null || echo "disabled")
        if [ "$dnd_status" = "enabled" ]; then
            echo "" | rofi -dmenu -p "Do Not Disturb is enabled" -theme-str 'window { width: 600px; } entry { enabled: false; } prompt { expand: true; horizontal-align: 0.5; }'
            exit 0
        fi
        
        # Get notifications from Dunst history
        history_output=$(dunstctl history 2>/dev/null)
        if [ -n "$history_output" ] && [ "$history_output" != "[]" ] && [ "$history_output" != "{\"data\": []}" ]; then
            # Create temp files to store notification mapping
            TMP_DIR=$(mktemp -d)
            touch "$TMP_DIR/notifications_list.txt"
            
            # Parse notifications and store with IDs
            echo "$history_output" | jq -r '.data[0][] | "\(.id.data)|\(.summary.data // "No Summary"): \(.body.data // "No Body")"' 2>/dev/null | while IFS='|' read -r id summary_body; do
                echo "$id|$summary_body" >> "$TMP_DIR/notifications_list.txt"
            done
            
            # Format notifications for rofi display (without IDs)
            notifications=$(cat "$TMP_DIR/notifications_list.txt" | cut -d'|' -f2)
            
            # If parsing failed, show error message instead of raw JSON
            if [ -z "$notifications" ]; then
                notifications="Error: Could not parse notifications"
                rm -rf "$TMP_DIR"
            fi
            
            # Add clear option to the top of the list
            options="🗑️ Clear All Notifications\n$notifications"
            
            selected=$(echo -e "$options" | rofi -dmenu -p "Notifications" -theme-str 'window { width: 600px; } listview { lines: 10; } entry { enabled: false; } prompt { expand: true; horizontal-align: 0.5; }')
            
            if [ -n "$selected" ]; then
                    case "$selected" in
                    "🗑️ Clear All Notifications")
                        # Clear all notifications using Dunst
                        dunstctl close-all
                        dunstctl history-clear
                        
                        # Show bell icon with DND class to prevent disappearing
                        echo "{\"text\": \"\", \"tooltip\": \"No notifications in history - Right-click to enable DND\", \"class\": \"no-notifications\"}"
                        
                        # Update Waybar immediately with empty state
                        pkill -RTMIN+9 waybar
                        
                        # Show confirmation after Waybar updates
                        notify-send "Notifications Cleared" "All notifications have been cleared" -t 2000
                        
                        # Cleanup
                        rm -rf "$TMP_DIR" 2>/dev/null
                        ;;
                    *)
                        # Regular notification selected - find the ID and open it
                        notification_id=$(grep -F "|$selected" "$TMP_DIR/notifications_list.txt" | head -1 | cut -d'|' -f1)
                        
                        if [ -n "$notification_id" ]; then
                            # Trigger the notification action using dunstctl
                            dunstctl action "$notification_id" 2>/dev/null || notify-send "Error" "Could not open notification" -t 2000
                        else
                            notify-send "Error" "Notification not found" -t 2000
                        fi
                        
                        # Cleanup
                        rm -rf "$TMP_DIR" 2>/dev/null
                        ;;
                esac
            else
                # Cleanup if no selection
                rm -rf "$TMP_DIR" 2>/dev/null
            fi
        else
            # No notifications - still show clear option
            selected=$(echo -e "🗑️ Clear All Notifications" | rofi -dmenu -p "No notifications" -theme-str 'window { width: 600px; } entry { enabled: false; } prompt { expand: true; horizontal-align: 0.5; }')
            if [ "$selected" = "🗑️ Clear All Notifications" ]; then
                # Clear all notifications using Dunst
                dunstctl close-all
                dunstctl history-clear
                
                # Show bell icon with DND class to prevent disappearing  
                echo "{\"text\": \"\", \"tooltip\": \"No notifications in history - Right-click to enable DND\", \"class\": \"no-notifications\"}"
                
                # Update Waybar immediately with empty state
                pkill -RTMIN+9 waybar
                
                # Show confirmation after Waybar updates
                notify-send "Notifications Cleared" "All notifications have been cleared" -t 2000
            fi
        fi
        ;;
    
    "count")
        # Use Dunst's history count instead of displayed (notifications disappear quickly)
        history_count=$(dunstctl count history 2>/dev/null || echo "0")
        dnd_status=$(cat "$DND_STATE" 2>/dev/null || echo "disabled")
        
        # Use history count for more stable display (notifications may disappear from display quickly)
        count=$history_count
        
        if [ "$dnd_status" = "enabled" ]; then
            echo "{\"text\": \"🈯\", \"tooltip\": \"Do Not Disturb Enabled - Right-click to disable\", \"class\": \"dnd-enabled\"}"
        elif [ "$count" -gt 0 ]; then
            echo "{\"text\": \" $count\", \"tooltip\": \"$count recent notifications - Click to view, Right-click for DND\", \"class\": \"has-notifications\"}"
        else
            echo "{\"text\": \"\", \"tooltip\": \"No notifications in history - Right-click to enable DND\", \"class\": \"no-notifications\"}"
        fi
        ;;
    
    "clear")
        # Clear all notifications using Dunst
        dunstctl close-all
        # Clear Dunst history
        dunstctl history-clear
        
        # Show bell icon with DND class to prevent disappearing
        echo "{\"text\": \"\", \"tooltip\": \"No notifications in history - Right-click to enable DND\", \"class\": \"no-notifications\"}"
        
        # Update Waybar immediately with empty state
        pkill -RTMIN+9 waybar
        ;;
    
    "dnd-toggle")
        # Toggle Do Not Disturb
        dnd_status=$(cat "$DND_STATE" 2>/dev/null || echo "disabled")
        
        if [ "$dnd_status" = "enabled" ]; then
            # Disable DND
            echo "disabled" > "$DND_STATE"
            dunstctl set-paused false
            notify-send "Do Not Disturb" "Disabled - Notifications will show" -t 2000
        else
            # Enable DND
            echo "enabled" > "$DND_STATE"
            dunstctl set-paused true
            notify-send "Do Not Disturb" "Enabled - Notifications paused" -t 2000
        fi
        
        pkill -RTMIN+9 waybar
        ;;
    
    "dnd-enable")
        # Enable Do Not Disturb
        echo "enabled" > "$DND_STATE"
        dunstctl set-paused true
        pkill -RTMIN+9 waybar
        ;;
    
    "dnd-disable")
        # Disable Do Not Disturb
        echo "disabled" > "$DND_STATE"
        dunstctl set-paused false
        pkill -RTMIN+9 waybar
        ;;
    
    "dnd-status")
        # Check DND status
        cat "$DND_STATE" 2>/dev/null || echo "disabled"
        ;;
    
    *)
        echo "Usage: $0 {show|count|clear|dnd-toggle|dnd-enable|dnd-disable|dnd-status}"
        exit 1
        ;;
esac