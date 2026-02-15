#!/bin/bash

# Function to get volume
get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'
}

# Function to get brightness
get_brightness() {
    brightnessctl i | grep -oP '\(\K[^%]+'
}

# Function to send notification - simplified for SwayNC
send_notification() {
    local type=$1
    local value=$2
    local icon=""
    local replace_id=""
    
    if [ "$type" = "volume" ]; then
        replace_id="9993"
        notify-send -a "Volume" -r "$replace_id" -h int:value:"$value" -t 1000 "Volume: ${value}%"
    elif [ "$type" = "brightness" ]; then
        replace_id="9994" 
        notify-send -a "Brightness" -r "$replace_id" -h int:value:"$value" -t 1000 "Brightness: ${value}%"
    elif [ "$type" = "volume_mute" ]; then
        replace_id="9993"
        if wpctl get-mute @DEFAULT_AUDIO_SINK@ | grep -q "Muted: yes"; then
            notify-send -a "Volume" -r "$replace_id" -t 1000 "Volume Muted"
        else
            current_volume=$(get_volume)
            notify-send -a "Volume" -r "$replace_id" -h int:value:"$current_volume" -t 1000 "Volume: ${current_volume}%"
        fi
    fi
}

case $1 in
    vol_up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        send_notification "volume" "$(get_volume)"
        ;;
    vol_down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        send_notification "volume" "$(get_volume)"
        ;;
    vol_mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        send_notification "volume_mute"
        ;;
    br_up)
        brightnessctl set 5%+
        send_notification "brightness" "$(get_brightness)"
        ;;
    br_down)
        brightnessctl set 5%-
        send_notification "brightness" "$(get_brightness)"
        ;;
esac
