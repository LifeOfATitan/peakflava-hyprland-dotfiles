#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# OPEN NVIM WITH DIRECTORY SELECTOR
# ═══════════════════════════════════════════════════════════════════

CACHE_FILE="$HOME/.cache/nvim_recent_dirs"
QUICK_DIRS=(
    "$HOME/.config"
    "$HOME/Crafono"
    "/documents/projects"
    "/documents/work"
    "$HOME/Obsidian"
)

# Ensure cache directory exists
mkdir -p "$(dirname "$CACHE_FILE")"

# Build menu items
menu_items=()

# Add recent directories from cache (max 5)
if [ -f "$CACHE_FILE" ]; then
    recent_count=0
    while IFS= read -r dir && [ $recent_count -lt 5 ]; do
        if [ -d "$dir" ]; then
            menu_items+=("[Recent] $(basename "$dir") ($dir)")
            ((recent_count++))
        fi
    done < "$CACHE_FILE"
    
    if [ $recent_count -gt 0 ]; then
        menu_items+=("---")
    fi
fi

# Add quick directories
for dir in "${QUICK_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Show nice name for known directories
        case "$dir" in
            "$HOME/.config") name="Config" ;;
            "$HOME/Crafono") name="Crafono" ;;
            "/documents/projects") name="Projects" ;;
            "/documents/work") name="Work" ;;
            "$HOME/Obsidian") name="Obsidian" ;;
            *) name=$(basename "$dir") ;;
        esac
        menu_items+=("$name ($dir)")
    fi
done

# Add special options
menu_items+=("---")
menu_items+=("Home directory (~)")
menu_items+=("Browse with file manager...")

# Show rofi menu
selected=$(printf '%s\n' "${menu_items[@]}" | rofi -dmenu -i -p "Open nvim in:" -theme-str 'window { width: 600px; }')

# Handle selection
if [ -z "$selected" ]; then
    # No selection - use last used directory if available, otherwise home
    if [ -f "$CACHE_FILE" ]; then
        target_dir=$(head -1 "$CACHE_FILE")
        if [ ! -d "$target_dir" ]; then
            target_dir="$HOME"
        fi
    else
        target_dir="$HOME"
    fi
else
    case "$selected" in
        "Home directory (~)")
            target_dir="$HOME"
            ;;
        "Browse with file manager...")
            # Use zenity to pick directory
            target_dir=$(zenity --file-selection --directory --title="Select directory for nvim" 2>/dev/null)
            if [ -z "$target_dir" ] || [ ! -d "$target_dir" ]; then
                exit 0
            fi
            ;;
        \[Recent\]*|\[Quick\]*)
            # Extract directory from format: "Name (/path/to/dir)"
            target_dir=$(echo "$selected" | sed 's/.*(\(.*\))$/\1/')
            ;;
        *)
            # Extract directory from format: "Name (/path/to/dir)"
            target_dir=$(echo "$selected" | sed 's/.*(\(.*\))$/\1/')
            ;;
    esac
fi

# Validate target directory
if [ ! -d "$target_dir" ]; then
    notify-send "Error" "Directory not found: $target_dir" -t 3000
    exit 1
fi

# Update cache (add to beginning, remove duplicates, keep last 10)
if [ -f "$CACHE_FILE" ]; then
    # Remove target_dir if it exists in cache, then add to top
    grep -vFx "$target_dir" "$CACHE_FILE" > "$CACHE_FILE.tmp" 2>/dev/null || true
    echo "$target_dir" > "$CACHE_FILE"
    head -9 "$CACHE_FILE.tmp" >> "$CACHE_FILE" 2>/dev/null || true
    rm -f "$CACHE_FILE.tmp"
else
    echo "$target_dir" > "$CACHE_FILE"
fi

# Open nvim in kitty (maximized to fill screen, waybar still visible)
kitty --start-as maximized --directory "$target_dir" nvim &
