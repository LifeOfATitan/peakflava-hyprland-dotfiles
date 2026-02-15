#!/bin/bash

# VIDEO WALLPAPER SWITCHER SCRIPT
# Randomly switches to video wallpapers using mpvpaper

WALLPAPER_DIR="$HOME/wallpapers"

# Check if mpvpaper is installed
if ! command -v mpvpaper &> /dev/null; then
    notify-send "Error" "mpvpaper is not installed. Install it with: yay -S mpvpaper" -t 5000
    exit 1
fi

# Find a random video file
video=$(find "$WALLPAPER_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" -o -name "*.mov" \) | shuf -n 1)

if [ -z "$video" ]; then
    notify-send "Error" "No video files found in $WALLPAPER_DIR" -t 3000
    exit 1
fi

# Get filename for notification
filename=$(basename "$video")

# Stop any existing mpvpaper instance
pkill mpvpaper 2>/dev/null
sleep 0.3

# Clear swww wallpaper to prevent it from showing behind video
if command -v swww &> /dev/null; then
    swww clear 2>/dev/null
fi
sleep 0.2

# Launch mpvpaper with optimized settings for battery life
# --no-audio: no sound
# --loop-file: loop the video
# --panscan=1.0: zoom to fill screen without black bars
# CPU decoding (no hwdec) for battery efficiency
mpvpaper -o "--loop-file --no-audio --panscan=1.0" "*" "$video" &

notify-send "Video Wallpaper" "Applied: $filename" -t 2000
