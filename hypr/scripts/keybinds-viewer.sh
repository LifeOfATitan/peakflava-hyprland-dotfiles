#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# KEYBINDS VIEWER FOR ROFI
# ═══════════════════════════════════════════════════════════════════

# Path to your keybinds file
KEYBINDS_FILE="$HOME/.config/hypr/keybinds.conf"

# Check if file exists
if [ ! -f "$KEYBINDS_FILE" ]; then
    notify-send "Error" "Keybinds file not found at $KEYBINDS_FILE"
    exit 1
fi

# Parse the keybinds file
keybinds=$(awk '
    BEGIN { 
        desc_width = 50
        first_category = 1
        workspace_count = 0
        workspace_cat = ""
    }
    
    /^# [A-Za-z]/ { 
        cat = substr($0, 3)
        # Skip generic headers
        if (cat == "KEYBINDINGS" || cat ~ /^Using SUPER/) next
        
        # Handle workspace category specially
        if (cat ~ /Workspaces/ && workspace_count > 0) {
            # Print summary of previous workspaces
            printf "  Go to workspace 1-10                       SUPER + 1-0, mouse scroll\n"
            printf "  Move window to workspace 1-5               SUPER SHIFT + 1-5\n"
            workspace_count = 0
        }
        
        # Skip empty categories from the file
        if (cat ~ /Move to workspace$/ || cat ~ /Mouse bindings$/ || cat ~ /Workspaces$/ || cat ~ /Scroll through workspaces$/) {
            next
        }
        
        if (first_category) {
            printf "═══ %s ═══\n", cat
            first_category = 0
        } else {
            printf "\n═══ %s ═══\n", cat
        }
        next 
    }
    
    /^bind[le]* =/ {
        line = $0
        gsub(/^bind[le]* = /, "", line)
        n = split(line, parts, ",")
        
        modifier = parts[1]
        key = parts[2]
        action = parts[3]
        
        gsub(/^[ \t]+|[ \t]+$/, "", modifier)
        gsub(/^[ \t]+|[ \t]+$/, "", key)
        gsub(/^[ \t]+|[ \t]+$/, "", action)
        
        gsub(/\$mainMod/, "SUPER", modifier)
        
        if (modifier == "") key_combo = key
        else key_combo = modifier " + " key
        
        cmd = action
        for (i = 4; i <= n; i++) {
            gsub(/^[ \t]+|[ \t]+$/, "", parts[i])
            if (parts[i] != "") cmd = cmd ", " parts[i]
        }
        
        # Skip individual workspace numbers
        if (cmd ~ /workspace, [0-9]$/ || cmd ~ /movetoworkspace, [0-9]$/) {
            workspace_count++
            next
        }
        
        desc = ""
        if (cmd ~ /^exec, /) {
            exec_cmd = cmd
            gsub(/^exec, /, "", exec_cmd)
            
            if (exec_cmd ~ /^\$terminal/ || exec_cmd ~ /kitty/) desc = "Open terminal"
            else if (exec_cmd ~ /^\$fileManager/ || exec_cmd ~ /thunar/) desc = "Open file manager"
            else if (exec_cmd ~ /^\$menu/ || exec_cmd ~ /rofi/) desc = "Open app menu"
            else if (exec_cmd ~ /firefox/) desc = "Open Firefox"
            else if (exec_cmd ~ /open-nvim/) desc = "Open editor"
            else if (exec_cmd ~ /wlogout/) desc = "Open power menu"
            else if (exec_cmd ~ /screenshot.sh.*area/) desc = "Screenshot (Area)"
            else if (exec_cmd ~ /screenshot.sh.*copy/) desc = "Screenshot (Copy only)"
            else if (exec_cmd ~ /screenshot.sh.*save-as/) desc = "Screenshot (Save As)"
            else if (exec_cmd ~ /playerctl.*play-pause/) desc = "Media: Play/Pause"
            else if (exec_cmd ~ /playerctl.*next/) desc = "Media: Next"
            else if (exec_cmd ~ /playerctl.*previous/) desc = "Media: Previous"
            else if (exec_cmd ~ /volume-brightness.*vol_up/) desc = "Volume up"
            else if (exec_cmd ~ /volume-brightness.*vol_down/) desc = "Volume down"
            else if (exec_cmd ~ /volume-brightness.*vol_mute/) desc = "Mute"
            else if (exec_cmd ~ /volume-brightness.*br_up/) desc = "Brightness up"
            else if (exec_cmd ~ /volume-brightness.*br_down/) desc = "Brightness down"
            else if (exec_cmd ~ /keybinds-viewer/) desc = "Show keybinds"
            else if (exec_cmd ~ /wallpaper-switcher.*manual/) desc = "Change wallpaper"
            else if (exec_cmd ~ /wallpaper-picker/) desc = "Wallpaper picker"
            else if (exec_cmd ~ /video-wallpaper-switcher/) desc = "Random video wallpaper"
            else if (exec_cmd ~ /theme-switcher/) desc = "Theme switcher"
            else if (exec_cmd ~ /toggle-notifications/) desc = "Toggle notifications"
            else if (exec_cmd ~ /killall waybar/) desc = "Reload Waybar"
            else desc = "Run: " exec_cmd
        }
        else if (cmd == "killactive,") desc = "Kill active window"
        else if (cmd == "exit,") desc = "Exit Hyprland"
        else if (cmd == "fullscreen, 0") desc = "Fullscreen"
        else if (cmd == "togglefloating,") desc = "Toggle floating"
        else if (cmd == "pseudo,") desc = "Pseudo tile"
        else if (cmd == "togglesplit,") desc = "Toggle split"
        else if (cmd ~ /movefocus/) {
            if (cmd ~ /, l/) desc = "Move focus left"
            else if (cmd ~ /, r/) desc = "Move focus right"
            else if (cmd ~ /, u/) desc = "Move focus up"
            else if (cmd ~ /, d/) desc = "Move focus down"
        }
        else if (cmd ~ /movewindow/) {
            if (cmd ~ /, l/) desc = "Move window left"
            else if (cmd ~ /, r/) desc = "Move window right"
            else if (cmd ~ /, u/) desc = "Move window up"
            else if (cmd ~ /, d/) desc = "Move window down"
        }
        else if (cmd ~ /resizeactive.*-50/) desc = "Resize left/up"
        else if (cmd ~ /resizeactive.*50/) desc = "Resize right/down"
        else if (cmd ~ /moveactive.*-50/) desc = "Move left/up"
        else if (cmd ~ /moveactive.*50/) desc = "Move right/down"
        else if (cmd ~ /togglespecialworkspace/) desc = "Toggle scratchpad"
        else if (cmd ~ /movetoworkspace, special/) desc = "Move to scratchpad"
        else if (cmd ~ /workspace, e\+1/ || cmd ~ /workspace, mouse_down/) desc = "Next workspace"
        else if (cmd ~ /workspace, e-1/ || cmd ~ /workspace, mouse_up/) desc = "Previous workspace"
        else if (cmd ~ /movetoworkspace/) desc = "Move to workspace"
        else if (cmd ~ /mouse:272/) desc = "Move window (mouse)"
        else if (cmd ~ /mouse:273/) desc = "Resize window (mouse)"
        else desc = ""
        
        if (length(desc) > 55) desc = substr(desc, 1, 55) "..."
        if (desc != "") printf "  %-*s%s\n", desc_width, desc, key_combo
    }
    
    END {
        # Print workspace summary at the end
        if (workspace_count > 0) {
            printf "\n═══ Workspaces ═══\n"
            printf "  Go to workspace 1-10                       SUPER + 1-0, mouse scroll\n"
            printf "  Move window to workspace 1-5               SUPER SHIFT + 1-5\n"
        }
    }
' "$KEYBINDS_FILE")

# Display in Rofi
if [ -n "$keybinds" ]; then
    echo "$keybinds" | rofi -dmenu -i -p "Keybinds" -theme-str 'window { width: 1000px; } listview { columns: 1; lines: 15; }'
else
    notify-send "Keybinds Viewer" "No keybinds found or parsed" -t 2000
fi
