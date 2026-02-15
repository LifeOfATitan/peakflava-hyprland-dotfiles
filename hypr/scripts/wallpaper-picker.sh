#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# peakFlava's OPTIMIZED WALLPAPER PICKER SCRIPT FOR ROFI
# Features: 3-column grid, background thumbnailing, GIF/Video support
# ═══════════════════════════════════════════════════════════════════

WALLPAPER_DIR="$HOME/wallpapers"
THUMBNAIL_DIR="$HOME/.cache/wallpaper_thumbnails"
THUMB_SIZE=400 # Matches the Rofi grid size

# Ensure thumbnail directory exists
mkdir -p "$THUMBNAIL_DIR"

# Function to generate a single thumbnail
generate_one_thumbnail() {
    local wallpaper="$1"
    local thumbnail="$2"
    local ext="${1##*.}"
    ext="${ext,,}"

    case "$ext" in
        mp4|mkv|webm|mov)
            ffmpeg -ss 00:00:01 -i "$wallpaper" -vframes 1 -vf "scale=${THUMB_SIZE}:-1" -y "$thumbnail" >/dev/null 2>&1
            ;;
        gif)
            # Take only the first frame of the GIF
            magick "${wallpaper}[0]" -resize "${THUMB_SIZE}x" "$thumbnail" >/dev/null 2>&1
            ;;
        *)
            # Standard images
            magick "$wallpaper" -resize "${THUMB_SIZE}x" "$thumbnail" >/dev/null 2>&1
            ;;
    esac
    
    # Check if generation actually succeeded
    if [ -f "$thumbnail" ]; then
        return 0
    else
        return 1
    fi
}

generate_thumbnails() {
    local new_count=0
    local jobs=0
    local max_jobs=$(nproc)
    
    # Temporary list to avoid multiple find calls
    local wall_list=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.bmp" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" -o -name "*.mov" \))
    
    while IFS= read -r wallpaper; do
        [ -z "$wallpaper" ] && continue
        
        local filename=$(basename "$wallpaper")
        # Use MD5 of the full path to avoid collisions and handle special characters
        local thumb_name=$(echo -n "$wallpaper" | md5sum | cut -d' ' -f1).jpg
        local thumbnail="$THUMBNAIL_DIR/$thumb_name"
        
        # Check if thumbnail is missing OR older than the source file
        if [ ! -f "$thumbnail" ] || [ "$wallpaper" -nt "$thumbnail" ]; then
            generate_one_thumbnail "$wallpaper" "$thumbnail" &
            ((new_count++))
            ((jobs++))
            
            # Limit background jobs to CPU core count
            if [ $jobs -ge $max_jobs ]; then
                wait -n
                ((jobs--))
            fi
        fi
    done <<< "$wall_list"
    
    wait # Wait for remaining jobs to finish
    
    if [ $new_count -gt 0 ]; then
        notify-send "Wallpaper Picker" "Processed $new_count wallpapers" -t 2000
    fi
}

show_picker() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        notify-send "Error" "Wallpaper directory not found"
        exit 1
    fi
    
    # Start generation in background but don't wait for all of them if they already exist
    # This allows Rofi to open instantly with existing thumbnails
    generate_thumbnails &
    local gen_pid=$!
    
    # Give it a tiny bit of time to start generating the first few if the cache is empty
    # If cache is full, this script will be instant.
    sleep 0.1
    
    # Build rofi list
    local rofi_input=""
    while IFS= read -r wallpaper; do
        [ -z "$wallpaper" ] && continue
        local filename=$(basename "$wallpaper")
        local thumb_name=$(echo -n "$wallpaper" | md5sum | cut -d' ' -f1).jpg
        local thumbnail="$THUMBNAIL_DIR/$thumb_name"
        
        if [ -f "$thumbnail" ]; then
            rofi_input+="${filename}\x00icon\x1f${thumbnail}\n"
        else
            # Fallback if thumbnail isn't ready yet
            rofi_input+="${filename}\n"
        fi
    done <<< "$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.bmp" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" -o -name "*.mov" \) | sort)"
    
    if [ -z "$rofi_input" ]; then
        notify-send "Error" "No wallpapers found"
        exit 1
    fi
    
    local selected
    selected=$(echo -e "$rofi_input" | rofi -dmenu -i -show-icons -p "Select Wallpaper" -theme-str '
        window { width: 1300px; }
        listview { columns: 3; lines: 1; spacing: 20px; padding: 20px; fixed-columns: true; }
        element { orientation: vertical; padding: 15px; border-radius: 12px; }
        element-icon { size: 380px; horizontal-align: 0.5; }
        element-text { horizontal-align: 0.5; vertical-align: 0.5; }
    ')
    
    if [ -n "$selected" ]; then
        local selected_file="$WALLPAPER_DIR/$selected"
        
        if [ -f "$selected_file" ]; then
            apply_wallpaper "$selected_file"
        else
            notify-send "Error" "Selected wallpaper not found"
        fi
    fi
}

apply_wallpaper() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}"
    
    case "$ext" in
        mp4|mkv|webm|mov)
            if command -v mpvpaper &> /dev/null; then
                pkill mpvpaper 2>/dev/null
                sleep 0.2
                command -v swww &>/dev/null && swww clear 2>/dev/null
                mpvpaper -o "--loop-file --no-audio --panscan=1.0" "*" "$file" &
                notify-send "Wallpaper Changed" "Applied video: $(basename "$file")" -t 2000
            else
                notify-send "Error" "mpvpaper is not installed" -t 3000
            fi
            ;;
        *)
            if command -v swww &> /dev/null; then
                pkill mpvpaper 2>/dev/null
                if ! pgrep -x "swww-daemon" > /dev/null; then
                    swww-daemon &
                    sleep 1
                fi
                swww img "$file" --transition-type random --transition-step 1 --transition-fps 60
                notify-send "Wallpaper Changed" "Applied: $(basename "$file")" -t 2000
            else
                notify-send "Error" "swww is not installed" -t 3000
            fi
            ;;
    esac
}

case "$1" in
    "picker") show_picker ;;
    "--refresh") 
        rm -rf "$THUMBNAIL_DIR"/*
        generate_thumbnails 
        ;;
    "--clear") rm -rf "$THUMBNAIL_DIR"/* ;;
    *) show_picker ;;
esac
