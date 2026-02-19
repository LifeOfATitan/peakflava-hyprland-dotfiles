#!/bin/bash

# ═══════════════════════════════════════
# SIMPLIFIED DYNAMIC THEME SWITCHER WITH FAVORITES
# ═════════════════════════════════════════════

# Define paths
CACHE_FILE="$HOME/.cache/hypr_colors.conf"
WAYBAR_CURRENT_CSS="$HOME/.config/waybar/style.css"
DUNST_CONFIG="$HOME/.config/dunst/dunstrc"
BTOP_THEME="$HOME/.config/btop/themes/peakFlava.theme"
WALLPAPER_DIR="$HOME/wallpapers"
FAVTHEMES_FILE="$HOME/.config/hypr/favthemes.conf"

# GTK Settings Paths
GTK3_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
GTK4_SETTINGS="$HOME/.config/gtk-4.0/settings.ini"
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"
FIREFOX_CHROME_DIR="$HOME/.mozilla/firefox"
THUNAR_CONFIG_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

# GTK Application Paths
QT5CT_CONFIG="$HOME/.config/qt5ct/qt5ct.conf"
QT6CT_CONFIG="$HOME/.config/qt6ct/qt6ct.conf"

# Colors for output
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Print functions
print_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Initialize favorites file if it doesn't exist
init_favthemes_file() {
    if [ ! -f "$FAVTHEMES_FILE" ]; then
        cat > "$FAVTHEMES_FILE" <<EOF
# Favorite Themes Configuration
next_theme_id=1
EOF
    fi
}

# Function to generate lighter color variants
generate_lighter_color() {
    local hex_color=$1
    local factor=${2:-0.6}
    
    local hex="${hex_color#\#}"
    # Ensure it is a valid 6-char hex
    if ! [[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]]; then
        echo "$hex_color"
        return
    fi
    
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    local result=$(awk -v r=$r -v g=$g -v b=$b -v f=$factor 'BEGIN {
        printf "#%02x%02x%02x", int(r + (255-r) * f), int(g + (255-g) * f), int(b + (255-b) * f)
    }')
    echo "${result:-$hex_color}"
}

# Function to generate darker color variants
generate_darker_color() {
    local hex_color=$1
    local factor=${2:-0.3}
    
    local hex="${hex_color#\#}"
    # Ensure it is a valid 6-char hex
    if ! [[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]]; then
        echo "$hex_color"
        return
    fi
    
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    local result=$(awk -v r=$r -v g=$g -v b=$b -v f=$factor 'BEGIN {
        printf "#%02x%02x%02x", int(r * f), int(g * f), int(b * f)
    }')
    echo "${result:-$hex_color}"
}

# Function to calculate contrasting text color (black or white)
get_contrasting_text_color() {
    local hex_color=$1
    
    # Remove # prefix
    local hex="${hex_color#\#}"
    
    # Validation
    if ! [[ "$hex" =~ ^[0-9a-fA-F]{6}$ ]]; then
        echo "#ffffff"
        return
    fi
    
    # Extract RGB values
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    # Calculate luminance using standard formula
    # L = 0.299*R + 0.587*G + 0.114*B
    local luminance=$(( (299 * r + 587 * g + 114 * b) / 1000))
    
    # Return high contrast colors
    if [ $luminance -gt 150 ]; then
        echo "#0a0e14"  # Very dark for light backgrounds
    else
        echo "#ffffff"  # Pure white for dark backgrounds
    fi
}

# Function to apply theme to BTOP
apply_btop_theme() {
    local accent=$1
    local accent_alt=$2
    local bg=$3
    local fg=$4
    
    mkdir -p "$(dirname "$BTOP_THEME")"
    
    cat > "$BTOP_THEME" <<EOF
theme[main_bg]="${bg}"
theme[main_fg]="${fg}"
theme[title]="${fg}"
theme[hi_fg]="${accent}"
theme[selected_bg]="${accent}"
theme[selected_fg]="${fg}"
theme[inactive_fg]="${accent_alt}"
theme[graph_text]="${fg}"
theme[meter_bg]="${bg}"
theme[proc_misc]="${accent_alt}"
theme[cpu_box]="${accent}"
theme[mem_box]="${accent_alt}"
theme[net_box]="${accent}"
theme[proc_box]="${accent_alt}"
theme[div_line]="${accent}"
theme[temp_start]="${accent_alt}"
theme[temp_mid]="${accent}"
theme[temp_end]="#ef4444"
theme[cpu_start]="${accent}"
theme[cpu_mid]="${accent_alt}"
theme[cpu_end]="${accent}"
theme[free_start]="${accent_alt}"
theme[free_mid]="${accent_alt}"
theme[free_end]="${accent}"
theme[cached_start]="${accent}"
theme[cached_mid]="${accent}"
theme[cached_end]="${accent_alt}"
theme[available_start]="${accent_alt}"
theme[available_mid]="${accent_alt}"
theme[available_end]="${accent}"
theme[used_start]="${accent}"
theme[used_mid]="${accent}"
theme[used_end]="#ef4444"
theme[download_start]="${accent_alt}"
theme[download_mid]="${accent_alt}"
theme[download_end]="${accent}"
theme[upload_start]="${accent_alt}"
theme[upload_mid]="${accent_alt}"
theme[upload_end]="${accent}"
theme[process_start]="${accent}"
theme[process_mid]="${accent_alt}"
theme[process_end]="${accent}"
EOF
}

# Function to apply GTK system settings
apply_gtk_settings() {
    local gtk_theme=$1
    local icon_theme=$2
    local cursor_theme=$3
    local font_name=$4
    local color_scheme=${5:-"prefer-dark"}
    
    # Apply via GSettings (system-wide)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
        gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
        gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
        gsettings set org.gnome.desktop.interface font-name "$font_name"
        gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
        gsettings set org.gnome.desktop.interface document-font-name "$font_name"
        gsettings set org.gnome.desktop.interface monospace-font-name "$font_name"
    fi
    
    # Create/update GTK3 settings.ini
    mkdir -p "$(dirname "$GTK3_SETTINGS")"
    cat > "$GTK3_SETTINGS" <<EOF
[Settings]
gtk-theme-name=$gtk_theme
gtk-icon-theme-name=$icon_theme
gtk-cursor-theme-name=$cursor_theme
gtk-font-name=$font_name
gtk-application-prefer-dark-theme=true
gtk-enable-animations=true
EOF

    # Create/update GTK4 settings.ini
    mkdir -p "$(dirname "$GTK4_SETTINGS")"
    cp "$GTK3_SETTINGS" "$GTK4_SETTINGS"
    
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t ~/.local/share/icons/ 2>/dev/null &
    fi
}

# Function to apply Qt settings
apply_qt_settings() {
    local icon_theme=$1
    local style=${2:-"Kvantum"}
    
    # Update Qt5CT configuration
    if [ -f "$QT5CT_CONFIG" ]; then
        sed -i "s/^icon_theme=.*/icon_theme=$icon_theme/" "$QT5CT_CONFIG"
        sed -i "s/^style=.*/style=$style/" "$QT5CT_CONFIG"
    fi
    
    # Update Qt6CT configuration
    if [ -f "$QT6CT_CONFIG" ]; then
        sed -i "s/^icon_theme=.*/icon_theme=$icon_theme/" "$QT6CT_CONFIG"
        sed -i "s/^style=.*/style=$style/" "$QT6CT_CONFIG"
    fi
}

# Function to apply Kitty terminal theme
apply_kitty_theme() {
    local accent=$1
    local bg=$2
    local fg=$3
    local accent_alt=${4:-$accent}
    
    if [ ! -f "$KITTY_CONFIG" ]; then
        return 0
    fi
    
    # Generate terminal colors based on theme
    local color1=$accent
    local color15=$accent_alt
    local color8=$(generate_lighter_color "$bg" 0.3)
    
    # Backup original config
    cp "$KITTY_CONFIG" "${KITTY_CONFIG}.backup"
    
    # Update colors in kitty.conf
    sed -i "s/^background .*/background $bg/" "$KITTY_CONFIG"
    sed -i "s/^foreground .*/foreground $fg/" "$KITTY_CONFIG"
    sed -i "s/^color0 .*/color0 $bg/" "$KITTY_CONFIG"
    sed -i "s/^color1 .*/color1 $color1/" "$KITTY_CONFIG"
    sed -i "s/^color15 .*/color15 $color15/" "$KITTY_CONFIG"
    sed -i "s/^color8 .*/color8 $color8/" "$KITTY_CONFIG"
    
    # Reload kitty if running
    if pgrep -x "kitty" > /dev/null; then
        killall -USR1 kitty 2>/dev/null
    fi
}

# Function to apply Thunar settings
apply_thunar_settings() {
    mkdir -p "$THUNAR_CONFIG_DIR"
    
    # Create/update Thunar configuration
    cat > "$THUNAR_CONFIG_DIR/thunar.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="thunar" version="1.0">
  <property name="last-view" type="string" value="ThunarIconView"/>
  <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_100_PERCENT"/>
  <property name="last-separator-position" type="int" value="170"/>
  <property name="misc-single-click" type="bool" value="false"/>
  <property name="misc-confirm-delete" type="bool" value="true"/>
  <property name="misc-show-hidden-files" type="bool" value="false"/>
</channel>
EOF
    
    # Update XFCE settings
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c thunar -p /last-view -s ThunarIconView 2>/dev/null
        xfconf-query -c thunar -p /misc-confirm-delete -s true 2>/dev/null
    fi
}

# Function to apply Firefox theme
apply_firefox_theme() {
    local accent=$1
    local bg=$2
    local fg=$3
    
    # Find Firefox profile directory
    local ff_profile=$(find "$FIREFOX_CHROME_DIR" -name "*.default-release" 2>/dev/null | head -1)
    if [ -n "$ff_profile" ]; then
        local chrome_dir="$ff_profile/chrome"
        mkdir -p "$chrome_dir"
        
        # Create userChrome.css
        cat > "$chrome_dir/userChrome.css" <<EOF
/* Firefox Theme Integration */
:root {
    --firefox-accent-color: ${accent};
    --firefox-bg-color: ${bg};
    --firefox-fg-color: ${fg};
    --firefox-light-accent: ${accent_alt};
}

#navigator-toolbox {
    background-color: var(--firefox-bg-color) !important;
    color: var(--firefox-fg-color) !important;
}

.tabbrowser-tab {
    background-color: var(--firefox-bg-color) !important;
    color: var(--firefox-fg-color) !important;
}

.tabbrowser-tab[selected="true"] {
    background-color: var(--firefox-accent-color) !important;
    color: white !important;
}

#urlbar {
    background-color: var(--firefox-bg-color) !important;
    color: var(--firefox-fg-color) !important;
    border: 1px solid var(--firefox-accent-color) !important;
}

#urlbar[focused="true"] {
    border-color: var(--firefox-accent-color) !important;
}

#nav-bar {
    background-color: var(--firefox-bg-color) !important;
}

.toolbarbutton-icon {
    fill: var(--firefox-fg-color) !important;
}
EOF
    fi
}

# Function to generate light theme colors
generate_light_colors() {
    local dark_accent=$1
    local dark_accent_alt=$2
    local dark_bg=$3
    local dark_fg=$4
    
    # Generate light variants
    local light_bg=$(generate_lighter_color "$dark_bg" 0.85)
    local light_fg=$(generate_darker_color "$dark_bg" 0.3)
    local light_accent=$(generate_lighter_color "$dark_accent" 0.2)
    local light_accent_alt=$(generate_lighter_color "$dark_accent_alt" 0.2)
    
    echo "$light_accent:$light_accent_alt:$light_bg:$light_fg"
}

# Function to apply colors to all applications
apply_colors() {
    local accent=$1
    local accent_alt=$2
    local bg=$3
    local fg=$4
    local mode=${5:-"dark"}
    local wallpaper=$6
    
    # Ensure variables are not empty (Fallbacks)
    [ -z "$accent" ] && accent="#8b5cf6"
    [ -z "$accent_alt" ] && accent_alt="#06b6d4"
    [ -z "$bg" ] && bg="#1e1e2e"
    [ -z "$fg" ] && fg="#d4d4d8"

    # Clean up input (remove possible trailing spaces or garbage)
    accent=$(echo "$accent" | tr -d '[:space:]')
    accent_alt=$(echo "$accent_alt" | tr -d '[:space:]')
    bg=$(echo "$bg" | tr -d '[:space:]')
    fg=$(echo "$fg" | tr -d '[:space:]')

    # Add hash if missing for local processing
    [[ ! "$accent" =~ ^# ]] && accent="#$accent"
    [[ ! "$accent_alt" =~ ^# ]] && accent_alt="#$accent_alt"
    [[ ! "$bg" =~ ^# ]] && bg="#$bg"
    [[ ! "$fg" =~ ^# ]] && fg="#$fg"

    # Final validation - if still invalid, use hard defaults
    ! [[ "$accent" =~ ^#[0-9a-fA-F]{6}$ ]] && accent="#8b5cf6"
    ! [[ "$accent_alt" =~ ^#[0-9a-fA-F]{6}$ ]] && accent_alt="#06b6d4"
    ! [[ "$bg" =~ ^#[0-9a-fA-F]{6}$ ]] && bg="#1e1e2e"
    ! [[ "$fg" =~ ^#[0-9a-fA-F]{6}$ ]] && fg="#d4d4d8"
    
    # Try to detect current wallpaper if not provided
    if [ -z "$wallpaper" ]; then
        wallpaper=$(swww query | grep "currently displaying: image: " | head -n 1 | awk -F 'image: ' '{print $2}' 2>/dev/null)
    fi
    
    # Generate color variants
    local lighter_accent=$(generate_lighter_color "$accent" 0.6)
    local much_lighter_accent=$(generate_lighter_color "$accent" 0.3)
    local lighter_accent_alt=$(generate_lighter_color "$accent_alt" 0.6)
    local much_lighter_accent_alt=$(generate_lighter_color "$accent_alt" 0.3)
    local lighter_bg=$(generate_lighter_color "$bg" 0.4)
    local much_lighter_bg=$(generate_lighter_color "$bg" 0.2)
    
    # Calculate contrasting text colors
    local text_on_accent=$(get_contrasting_text_color "$accent")
    local text_on_accent_alt=$(get_contrasting_text_color "$accent_alt")
    local text_on_lighter_accent=$(get_contrasting_text_color "$lighter_accent")
    local text_on_much_lighter_accent=$(get_contrasting_text_color "$much_lighter_accent")
    local text_on_lighter_accent_alt=$(get_contrasting_text_color "$much_lighter_accent_alt")
    local text_on_lighter_bg=$(get_contrasting_text_color "$lighter_bg")
    local text_on_much_lighter_bg=$(get_contrasting_text_color "$much_lighter_bg")
    local text_on_bg=$(get_contrasting_text_color "$bg")
    
    # Update Hyprland colors (Atomic write to prevent fleeting parsing errors)
    cat > "${CACHE_FILE}.tmp" <<EOF
\$accent = rgb(${accent#\#})
\$accent_alt = rgb(${accent_alt#\#})
\$background = rgb(${bg#\#})
\$foreground = rgb(${fg#\#})
EOF
    mv "${CACHE_FILE}.tmp" "$CACHE_FILE"

    # Update Hyprlock specific colors (hex only - Atomic write)
    cat > "$HOME/.cache/hyprlock_colors.conf.tmp" <<EOF
\$accent_hex = ${accent#\#}
\$accent_alt_hex = ${accent_alt#\#}
\$background_hex = ${bg#\#}
\$foreground_hex = ${fg#\#}
EOF
    mv "$HOME/.cache/hyprlock_colors.conf.tmp" "$HOME/.cache/hyprlock_colors.conf"

    # Instantly apply border colors to Hyprland (Avoids fleeting parsing errors on reload)
    hyprctl keyword general:col.active_border "rgb(${accent#\#}) rgb(${accent_alt#\#}) 45deg" 2>/dev/null
    
    # Generate Waybar CSS with specified colors
    cat > "$WAYBAR_CURRENT_CSS" <<CSS
/* MINIMAL WORKING WAYBAR CSS - AUTO-CONTRAST TEXT */

/* Main Waybar Bar - Transparent background */
window#waybar {
    background: transparent;
}

/* Individual Module Colors - Auto-Contrast Text */
#custom-launcher {
    background-color: ${accent};
    color: ${text_on_accent};
    font-size: 20px;
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#clock {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
}

#idle_inhibitor {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#idle_inhibitor.activated {
    background-color: ${text_on_accent_alt};
    color: ${accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#custom-weather_themed {
    background-color: ${accent};
    color: ${text_on_accent};
    text-shadow: 0 0 2px rgba(0,0,0,0.5);
    padding: 6px 8px;
    margin: 6px 3px;
}

/* Workspaces - Enhanced Visibility */
#workspaces {
    background: transparent;
}

#workspaces button {
    background-color: ${bg};
    color: ${text_on_bg};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
    border: 1px solid ${lighter_bg};
    transition: all 0.2s ease;
}

#workspaces button:hover {
    background-color: ${lighter_bg};
    border-color: ${accent};
}

#workspaces button.active {
    background-color: ${accent};
    color: ${text_on_accent};
    border-color: ${accent};
    border-width: 2px;
}

#window {
    background-color: ${bg};
    color: ${text_on_bg};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#window:hover {
    background-color: ${lighter_bg};
}

#tray {
    background-color: ${bg};
    color: ${text_on_bg};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#network {
    background-color: ${accent};
    color: ${text_on_accent};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#custom-orbit {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#cpu {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#pulseaudio {
    background-color: ${accent};
    color: ${text_on_accent};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#pulseaudio.muted {
    background-color: ${much_lighter_bg};
    color: ${text_on_much_lighter_bg};
}

#backlight {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#battery {
    background-color: ${accent};
    color: ${text_on_accent};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#battery.charging {
    background-color: ${lighter_accent};
    color: ${text_on_lighter_accent};
}

#battery.warning {
    background-color: #f59e0b;
    color: $(get_contrasting_text_color "#f59e0b");
}

#battery.critical {
    background-color: #ef4444;
    color: $(get_contrasting_text_color "#ef4444");
}

#tray {
    background-color: ${bg};
    color: ${text_on_bg};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#tray menu {
    background-color: ${bg};
    color: ${text_on_bg};
}


#battery.critical {
    background-color: #ef4444;
    color: #ffffff;
}

#custom-clipboard {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#custom-notification {
    background-color: ${accent};
    color: ${text_on_accent};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}

#custom-power {
    background-color: ${accent_alt};
    color: ${text_on_accent_alt};
    padding: 6px 12px;
    margin: 6px 3px;
    border-radius: 4px;
}
CSS
    
    # Determine theme settings based on mode
    local gtk_theme icon_theme cursor_theme font_name color_scheme
    if [ "$mode" = "light" ]; then
        gtk_theme="Catppuccin-Latte"
        icon_theme="Papirus-Light"
        cursor_theme="Bibata-Modern-Ice"
        font_name="JetBrains Mono 11"
        color_scheme="default"
    else
        gtk_theme="Catppuccin-Mocha"
        icon_theme="Papirus-Dark"
        cursor_theme="Bibata-Modern-Ice"
        font_name="JetBrains Mono 11"
        color_scheme="prefer-dark"
    fi
    
    # Apply GTK system settings
    apply_gtk_settings "$gtk_theme" "$icon_theme" "$cursor_theme" "$font_name" "$color_scheme"
    
    # Apply Qt settings
    apply_qt_settings "$icon_theme" "Kvantum"
    
    # Apply application-specific themes
    apply_kitty_theme "$accent" "$bg" "$fg" "$accent_alt"
    apply_btop_theme "$accent" "$accent_alt" "$bg" "$fg"
    apply_thunar_settings
    apply_firefox_theme "$accent" "$bg" "$fg"
    
    # Update Dunst colors (if config exists)
    if [ -f "$DUNST_CONFIG" ]; then
        # Ensure fg and bg have # prefix for Dunst
        local dunst_bg="$bg"
        local dunst_fg="$fg"
        [[ ! "$dunst_bg" =~ ^# ]] && dunst_bg="#$dunst_bg"
        [[ ! "$dunst_fg" =~ ^# ]] && dunst_fg="#$dunst_fg"
        local dunst_accent="$accent"
        local dunst_accent_alt="$accent_alt"
        [[ ! "$dunst_accent" =~ ^# ]] && dunst_accent="#$dunst_accent"
        [[ ! "$dunst_accent_alt" =~ ^# ]] && dunst_accent_alt="#$dunst_accent_alt"

        # Global replacements for background and foreground (handles both empty and hex values)
        sed -i "s/background = \".*\"/background = \"${dunst_bg}\"/g" "$DUNST_CONFIG"
        sed -i "s/foreground = \".*\"/foreground = \"${dunst_fg}\"/g" "$DUNST_CONFIG"
        
        # Ensure foreground is set to a contrasting color if it's still generic
        if grep -q 'foreground = ""' "$DUNST_CONFIG"; then
             sed -i "s/foreground = \"\"/foreground = \"${dunst_fg}\"/g" "$DUNST_CONFIG"
        fi
        
        # Global replacement for frame_color (default to primary accent)
        sed -i "s/frame_color = \".*\"/frame_color = \"${dunst_accent}\"/g" "$DUNST_CONFIG"
        
        # Specific override for urgency_low to use accent_alt
        sed -i "/\[urgency_low\]/,/\[/ s/frame_color = \".*\"/frame_color = \"${dunst_accent_alt}\"/" "$DUNST_CONFIG"
        
        # Update specific rules to use secondary accent
        sed -i "/\[volume\]/,/\[/ s/frame_color = \".*\"/frame_color = \"${dunst_accent_alt}\"/" "$DUNST_CONFIG"
        sed -i "/\[brightness\]/,/\[/ s/frame_color = \".*\"/frame_color = \"${dunst_accent_alt}\"/" "$DUNST_CONFIG"
    fi
    
    # Update Wlogout colors
    local WLOGOUT_STYLE="$HOME/.config/wlogout/style.css"
    
    if [ -f "$WLOGOUT_STYLE" ]; then
        # Convert hex colors to RGB for rgba
        local bg_r=$(printf "%d" 0x${bg:1:2})
        local bg_g=$(printf "%d" 0x${bg:3:2})
        local bg_b=$(printf "%d" 0x${bg:5:2})
        
        # Calculate lighter background (30% lighter)
        local lighter_r=$(( bg_r + (255 - bg_r) * 3 / 10 ))
        local lighter_g=$(( bg_g + (255 - bg_g) * 3 / 10 ))
        local lighter_b=$(( bg_b + (255 - bg_b) * 3 / 10 ))
        
        # Convert accent colors to RGBA format
        local accent_r=$(printf "%d" 0x${accent:1:2})
        local accent_g=$(printf "%d" 0x${accent:3:2})
        local accent_b=$(printf "%d" 0x${accent:5:2})
        local accent_alt_r=$(printf "%d" 0x${accent_alt:1:2})
        local accent_alt_g=$(printf "%d" 0x${accent_alt:3:2})
        local accent_alt_b=$(printf "%d" 0x${accent_alt:5:2})
        
        # Generate new wlogout CSS with current theme colors
        cat > "$WLOGOUT_STYLE" <<EOF
/* ═══════════════════════════════════════════════════════════════════
   WLOGOUT STYLE - THEME MATCHED
   Generated: $(date)
   ═══════════════════════════════════════════════════════════════════ */

* {
    background-image: none;
    transition: all 200ms ease;
}

window {
    background-color: rgba(${bg_r}, ${bg_g}, ${bg_b}, 0.95);
}

button {
    color: ${fg};
    background-color: rgba(${lighter_r}, ${lighter_g}, ${lighter_b}, 0.7);
    outline-style: none;
    border: 2px solid transparent;
    border-radius: 16px;
    margin: 24px;
    min-width: 140px;
    min-height: 140px;
    background-repeat: no-repeat;
    background-position: center;
    background-size: 37%;
    font-family: "JetBrainsMono Nerd Font", sans-serif;
    font-size: 16px;
    font-weight: 600;
}

button:focus,
button:active,
button:hover {
    background-color: rgba(${accent_r}, ${accent_g}, ${accent_b}, 0.4);
    border-color: ${accent};
    outline-style: none;
}

button:focus {
    box-shadow: 0 0 20px rgba(${accent_r}, ${accent_g}, ${accent_b}, 0.5);
}

button:active {
    background-color: rgba(${accent_alt_r}, ${accent_alt_g}, ${accent_alt_b}, 0.5);
    border-color: ${accent_alt};
}

#lock {
    background-image: url("/usr/share/wlogout/icons/lock.png");
}

#logout {
    background-image: url("/usr/share/wlogout/icons/logout.png");
}

#suspend {
    background-image: url("/usr/share/wlogout/icons/suspend.png");
}

#hibernate {
    background-image: url("/usr/share/wlogout/icons/hibernate.png");
}

#shutdown {
    background-image: url("/usr/share/wlogout/icons/shutdown.png");
}

#reboot {
    background-image: url("/usr/share/wlogout/icons/reboot.png");
}
EOF
    fi

    # Generate Rofi colors
    cat > "$HOME/.cache/rofi_colors.rasi" <<EOF
* {
    bg-primary:         ${bg}F0;
    bg-selected:        ${accent};
    bg-selected-alt:    ${accent_alt};
    accent-primary:     ${accent};
    accent-secondary:   ${accent_alt};
    border-color:       ${accent};
    fg-selected:        ${text_on_accent};
    fg-selected-alt:    ${text_on_accent_alt};
    fg-primary:         ${fg};
}
EOF

    # Generate blurred wallpaper for Hyprlock
    if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
        print_info "Generating blurred wallpaper for Hyprlock..."
        magick "$wallpaper" -resize 10% -blur 0x8 -resize 1000% "$HOME/.cache/blurred_wallpaper.png" 2>/dev/null
    fi
    
    # Reload components
    sync # Ensure files are written to disk
    sleep 0.1
    # hyprctl reload (Disabled to prevent double-reload flickering)
    
    # Restart Waybar (fastest method)
    killall waybar
    waybar >/dev/null 2>&1 & disown
    
    # Reload Notification Daemon (Dunst)
    killall dunst 2>/dev/null
    sleep 0.5
    dunst &
    
    # Sync Orbit Theme
    bash "$HOME/.config/hypr/scripts/sync-orbit-theme.sh" "$accent" "$accent_alt" "$bg" "$fg"
}

# Load theme list from config file
load_theme_list() {
    if [ ! -f "$FAVTHEMES_FILE" ]; then
        return
    fi
    
    # Get next theme ID
    local next_id=$(grep "next_theme_id=" "$FAVTHEMES_FILE" | cut -d'=' -f2)
    
    # Load all themes
    for ((i=1; i<next_id; i++)); do
        local theme_name=$(grep "theme_${i}_name=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
        if [ -n "$theme_name" ]; then
            local theme_primary=$(grep "theme_${i}_primary=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
            local theme_secondary=$(grep "theme_${i}_secondary=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
            local theme_bg=$(grep "theme_${i}_bg=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
            local theme_fg=$(grep "theme_${i}_fg=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
            
            if [ -n "$theme_primary" ] && [ -n "$theme_secondary" ]; then
                echo "$i:$theme_name:$theme_primary:$theme_secondary:$theme_bg:$theme_fg"
            fi
        fi
    done
}

# Save current theme as favorite
save_favtheme() {
    local primary="$1"
    local secondary="$2"
    local bg="$3"
    local fg="$4"
    
    local name=$(echo "" | rofi -dmenu -i -p "Enter theme name:" -theme-str 'window {width: 600px;}' 2>/dev/null)
    if [ -z "$name" ]; then
        return
    fi
    
    # Sanitize name (remove colons as they are separators)
    name=${name//:/}
    
    # Check for duplicate names
    if grep -q "name=\"$name\"" "$FAVTHEMES_FILE"; then
        notify-send "Error" "Theme name already exists."
        return
    fi
    
    # Get next ID
    local id=$(grep "next_theme_id=" "$FAVTHEMES_FILE" | cut -d'=' -f2)
    
    # Append theme
    cat >> "$FAVTHEMES_FILE" <<EOF
theme_${id}_name="${name}"
theme_${id}_primary="${primary}"
theme_${id}_secondary="${secondary}"
theme_${id}_bg="${bg}"
theme_${id}_fg="${fg}"
EOF

    # Update next ID
    local next_id=$((id + 1))
    sed -i "s/next_theme_id=$id/next_theme_id=$next_id/" "$FAVTHEMES_FILE"
    
    notify-send "Theme Saved" "Theme '$name' saved to favorites."
}

# Manage favorites (Rename/Delete)
manage_favorites() {
    while true; do
        mapfile -t themes < <(load_theme_list)
        
        if [ ${#themes[@]} -eq 0 ]; then
            notify-send "No Favorites" "No saved favorite themes found."
            return
        fi
        
        # Create display list
        local display_list=()
        for theme in "${themes[@]}"; do
            local name=$(echo "$theme" | cut -d':' -f2)
            display_list+=("$name")
        done
        
        # Add Back option
        display_list+=("Back")
        
        # Select theme
        local choice=$(printf '%s\n' "${display_list[@]}" | rofi -dmenu -i -p "Select theme to manage:" -theme-str 'window {width: 600px;}' 2>/dev/null)
        
        if [ -z "$choice" ] || [ "$choice" = "Back" ]; then
            return
        fi
        
        # Find ID for choice
        local selected_id=""
        for theme in "${themes[@]}"; do
            local id=$(echo "$theme" | cut -d':' -f1)
            local name=$(echo "$theme" | cut -d':' -f2)
            if [ "$name" = "$choice" ]; then
                selected_id="$id"
                break
            fi
        done
        
        if [ -z "$selected_id" ]; then
            continue
        fi
        
        # Select action
        local action=$(echo -e "Rename\nDelete\nBack" | rofi -dmenu -i -p "Action for '$choice':" -theme-str 'window {width: 600px;}' 2>/dev/null)
        
        case "$action" in
            "Rename")
                local new_name=$(echo "$choice" | rofi -dmenu -i -p "New name:" -theme-str 'window {width: 600px;}' 2>/dev/null)
                if [ -n "$new_name" ] && [ "$new_name" != "$choice" ]; then
                    # Sanitize
                    new_name=${new_name//:/}
                    
                    # Check for duplicate
                    if grep -q "name=\"$new_name\"" "$FAVTHEMES_FILE"; then
                         notify-send "Error" "Theme name already exists."
                    else
                        sed -i "s/theme_${selected_id}_name=\"${choice}\"/theme_${selected_id}_name=\"${new_name}\"/" "$FAVTHEMES_FILE"
                        notify-send "Theme Renamed" "Renamed to: $new_name"
                    fi
                fi
                ;;
            "Delete")
                local confirm=$(echo -e "No\nYes" | rofi -dmenu -i -p "Delete '$choice'?" -theme-str 'window {width: 600px;}' 2>/dev/null)
                if [ "$confirm" = "Yes" ]; then
                    # Use stricter pattern matching for deletion to avoid partial matches
                    sed -i "/^theme_${selected_id}_/d" "$FAVTHEMES_FILE"
                    notify-send "Theme Deleted" "Theme '$choice' deleted."
                fi
                ;;
            *)
                # Go back to loop start
                ;;
        esac
    done
}

# Show favorites list for selection and application
show_favorites_list() {
    mapfile -t themes < <(load_theme_list)
    
    if [ ${#themes[@]} -eq 0 ]; then
        notify-send "No Favorites" "No saved favorite themes found."
        return
    fi
    
    # Create display list
    local display_list=()
    for theme in "${themes[@]}"; do
        local name=$(echo "$theme" | cut -d':' -f2)
        display_list+=("$name")
    done
    
    # Show rofi selection
    local choice=$(printf '%s\n' "${display_list[@]}" | rofi -dmenu -i -p "Select Favorite Theme" -theme-str 'window {width: 600px;}' 2>/dev/null)
    
    if [ -z "$choice" ]; then
        return
    fi
    
    # Find selected theme data
    for theme in "${themes[@]}"; do
        local name=$(echo "$theme" | cut -d':' -f2)
        if [ "$name" = "$choice" ]; then
            local primary=$(echo "$theme" | cut -d':' -f3)
            local secondary=$(echo "$theme" | cut -d':' -f4)
            local bg=$(echo "$theme" | cut -d':' -f5)
            local fg=$(echo "$theme" | cut -d':' -f6)
            
            apply_colors "$primary" "$secondary" "$bg" "$fg" "dark" ""
            notify-send "Theme Applied" "Applied favorite: $name"
            return
        fi
    done
}

# Wallpaper-based theme workflow with Pywal
wallpaper_based_theme_workflow() {
    if ! command -v wal &> /dev/null; then
        notify-send "Error" "Pywal is not installed."
        return 1
    fi
    
    local current_wall=$(swww query | grep "currently displaying: image: " | head -n 1 | awk -F 'image: ' '{print $2}' 2>/dev/null)
    local is_video=false
    local frame_file=""
    
    # Check if current wallpaper is a video
    if [ -n "$current_wall" ] && [ -f "$current_wall" ]; then
        local ext="${current_wall##*.}"
        ext="${ext,,}"  # lowercase
        case "$ext" in
            mp4|mkv|webm|mov)
                is_video=true
                ;;
        esac
    fi
    
    # If no current wallpaper or not found, pick a random one
    if [ -z "$current_wall" ] || [ ! -f "$current_wall" ]; then
        current_wall=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" -o -name "*.mov" \) | shuf -n 1)
        
        # Check if random selection is video
        if [ -n "$current_wall" ]; then
            local ext="${current_wall##*.}"
            ext="${ext,,}"
            case "$ext" in
                mp4|mkv|webm|mov)
                    is_video=true
                    ;;
            esac
        fi
    fi
    
    if [ -z "$current_wall" ]; then
        notify-send "Error" "No wallpaper found."
        return 1
    fi
    
    # If it's a video, extract a frame for color analysis
    if [ "$is_video" = true ]; then
        notify-send "Analyzing Video" "Extracting frame from video for color analysis..."
        frame_file="/tmp/video_frame_$(date +%s).jpg"
        
        # Extract frame at 5 seconds (or first frame if video is shorter)
        ffmpeg -ss 00:00:05 -i "$current_wall" -vframes 1 -vf "scale=1920:-1" -y "$frame_file" 2>/dev/null
        
        # If extraction failed, try first frame
        if [ ! -f "$frame_file" ]; then
            ffmpeg -ss 00:00:01 -i "$current_wall" -vframes 1 -vf "scale=1920:-1" -y "$frame_file" 2>/dev/null
        fi
        
        if [ -f "$frame_file" ]; then
            current_wall="$frame_file"
        else
            notify-send "Error" "Failed to extract frame from video"
            return 1
        fi
    fi
    
    # Ensure wal config directory exists and is not a broken symlink
    if [ -L "$HOME/.config/wal" ] && [ ! -e "$HOME/.config/wal" ]; then
        rm "$HOME/.config/wal"
    fi
    mkdir -p "$HOME/.config/wal" 2>/dev/null
    
    # Generate colors from wallpaper
    notify-send "Analyzing Wallpaper" "Generating theme from current wallpaper..."
    
    wal -i "$current_wall" -n -q 2>/dev/null
    if [ $? -eq 0 ]; then
        source "$HOME/.cache/wal/colors.sh" 2>/dev/null
        apply_colors "$color5" "$color6" "$background" "$foreground" "dark" "$current_wall"
        notify-send "Theme Applied" "Wallpaper-based theme generated"
        
        # Clean up temp frame file if it was a video
        if [ -n "$frame_file" ] && [ -f "$frame_file" ]; then
            rm -f "$frame_file"
        fi
        
        # Check if theme already exists in favorites
        local theme_exists=false
        local existing_name=""
        
        if [ -f "$FAVTHEMES_FILE" ]; then
            local next_id=$(grep "next_theme_id=" "$FAVTHEMES_FILE" | cut -d'=' -f2)
            for ((i=1; i<next_id; i++)); do
                local s_p=$(grep "theme_${i}_primary=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                local s_s=$(grep "theme_${i}_secondary=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                local s_bg=$(grep "theme_${i}_bg=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                local s_fg=$(grep "theme_${i}_fg=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                
                # Case insensitive comparison
                if [[ "${s_p,,}" == "${color5,,}" ]] && \
                   [[ "${s_s,,}" == "${color6,,}" ]] && \
                   [[ "${s_bg,,}" == "${background,,}" ]] && \
                   [[ "${s_fg,,}" == "${foreground,,}" ]]; then
                    theme_exists=true
                    existing_name=$(grep "theme_${i}_name=" "$FAVTHEMES_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
                    break
                fi
            done
        fi

        if [ "$theme_exists" = true ]; then
             notify-send "Theme Known" "Matches favorite: '$existing_name'"
        else
            # Ask if user wants to save as favorite
            local save_choice=$(echo -e "No\nYes" | rofi -dmenu -i -p "Save this theme as favorite?" -theme-str 'window {width: 600px;}' 2>/dev/null)
            
            if [[ "$save_choice" == "Yes" ]]; then
                save_favtheme "$color5" "$color6" "$background" "$foreground"
            fi
        fi
    else
        notify-send "Error" "Failed to analyze wallpaper colors"
        # Clean up temp frame file on failure too
        if [ -n "$frame_file" ] && [ -f "$frame_file" ]; then
            rm -f "$frame_file"
        fi
    fi
}

# Main theme menu
show_theme_menu() {
    local from_keybind="$1"
    
    init_favthemes_file
    
    # Count favorite themes
    local themes=($(load_theme_list))
    local has_favorites=false
    if [ ${#themes[@]} -gt 0 ]; then
        has_favorites=true
    fi
    
    # Build menu options
    local options="Default Theme\nWallpaper-based Theme\nManage Favorites"
    
    if [ "$has_favorites" = true ]; then
        options="Apply Favorite Theme\n$options"
    fi
    
    local choice=$(echo -e "$options" | rofi -dmenu -i -p "Theme Options" -theme-str 'window {width: 600px;}' 2>/dev/null)
    
    # Handle ESC
    if [[ -z "$choice" ]]; then
        return 0  # Clean exit
    fi
    
    case "$choice" in
        "Apply Favorite Theme")
            show_favorites_list
            ;;
        "Default Theme")
            apply_colors "#8b5cf6" "#06b6d4" "#1e1e2e" "#d4d4d8" "dark" ""
            bash "$HOME/.config/hypr/scripts/sync-orbit-theme.sh" default
            notify-send "Theme Applied" "Default theme applied"
            ;;
        "Wallpaper-based Theme")
            wallpaper_based_theme_workflow
            ;;
        "Manage Favorites")
            manage_favorites
            ;;
        *)
            # Invalid selection - show menu again
            show_theme_menu "$from_keybind"
            ;;
    esac
}

# Handle keybind vs direct execution
case "$1" in
    "default"|"--default")
        # Apply default theme directly
        init_favthemes_file
        apply_colors "#8b5cf6" "#06b6d4" "#1e1e2e" "#d4d4d8" "dark"
        ;;
    "keybind")
        show_theme_menu "true"
        ;;
    *)
        show_theme_menu "false"
        ;;
esac