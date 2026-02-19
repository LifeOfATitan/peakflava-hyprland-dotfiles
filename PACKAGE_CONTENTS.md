# Package Contents

This document provides an overview of all files included in **peakFlava's** custom Hyprland dotfiles package.

---

## 📁 Directory Structure

```
custom-hyprland-dotfiles/
├── hypr/                          # Hyprland configuration
│   ├── hyprland.conf             # Main Hyprland config
│   ├── keybinds.conf             # Keyboard shortcuts
│   ├── scripts/                  # Hyprland specific scripts (Theme switcher, etc.)
│   └── themes/                   # Color theme configurations
├── waybar/                        # Waybar status bar
│   ├── config.jsonc              # Waybar modules configuration
│   ├── style.css                 # Waybar styling (Transparency support)
│   └── scripts/                  # Waybar helper scripts
├── rofi/                          # Rofi application launcher
│   └── config.rasi               # Rofi theme and configuration
├── kitty/                         # Kitty terminal emulator
│   └── kitty.conf                # Terminal configuration
├── dunst/                         # Dunst notification daemon
│   └── dunstrc                   # Notification styling
├── orbit/                         # Orbit WiFi/Bluetooth Manager ([Source](https://github.com/LifeOfATitan/orbit))
│   └── theme.toml                # Orbit color configuration
├── zsh/                           # Zsh shell configuration
│   ├── .zshrc                    # Zsh configuration with productivity functions
│   └── custom-theme.zsh-theme    # Custom Oh My Zsh theme
├── wallpapers/                    # Placeholder for your wallpapers
├── install.sh                     # peakFlava's Automated installation script
├── reset-dotfiles.sh              # peakFlava's Reset & Recovery tool
├── README.md                      # Main documentation
├── QUICKSTART.md                  # Quick start guide
├── COLOR_SCHEME.md                # Color palette reference
└── PACKAGE_CONTENTS.md            # This file
```

---

## 📄 Key File Descriptions

### `hypr/scripts/theme-switcher.sh`
**Purpose**: The heart of the dynamic theming system. Extracts colors from the current wallpaper (including video frames) and applies them system-wide using Pywal.

### `zsh/.zshrc`
**Purpose**: Highly optimized shell configuration. Includes custom window management functions for `nvim`, `tmux`, and `opencode` that automatically handle Hyprland tiling and resizing.

### `waybar/style.css`
**Purpose**: Advanced CSS styling with support for dynamic transparency and blur, synchronized with the current system theme.

---

## 👤 Author
- **peakFlava**
