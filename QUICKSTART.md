# peakFlava's Quick Start Guide

Welcome to your custom Hyprland environment! This guide will help you get comfortable with your new setup.

---

## 🚀 First Steps After Installation

### 1. The Welcome Message
When you open your terminal (Kitty) with `SUPER + RETURN`, you'll be greeted with your custom welcome message. This is a good time to check if all your paths and aliases are working.

### 2. Generate Your First Theme
Your setup uses a dynamic theming system. To make everything match your wallpaper:
1. Ensure you have a wallpaper in `~/wallpapers/`
2. Press `SUPER + CTRL + T` to open the **Theme Switcher**
3. Select **Wallpaper-based Theme**
4. Your colors for Waybar, Kitty, and Rofi will update automatically!

---

## ⌨️ Essential Keybindings

### The "Big Four"
```
SUPER + RETURN       → Open Terminal (Kitty)
SUPER + A            → Open App Launcher (Rofi)
SUPER + Q            → Close Active Window
SUPER + ESC          → Power Menu (wlogout)
```

### Productivity Functions
Your `.zshrc` includes custom functions that resize windows automatically for a better workflow:
- `nvim` / `v`     → Opens Neovim in a centered, 90% size window.
- `opencode`       → Opens Opencode in a large, centered window.
- `tmux`           → Opens Tmux in a centered, 90% size window.

### System Control
```
SUPER + F            → Toggle Fullscreen
SUPER + V            → Toggle Floating Mode
SUPER + CTRL + T     → Theme Switcher Menu
```

---

## 🔧 Maintenance

### Updating Your Dotfiles
If you make changes to your active config and want to save them to your backup folder:
1. Navigate to your dotfiles directory:
   ```bash
   cd ~/Documents/custom_setup/custom-hyprland-dotfiles
   ```
2. You can manually copy your changes or use `rsync` to mirror your `.config` folders back here.

### Resetting to Defaults
If something goes wrong, use the **Reset Tool**:
```bash
cd ~/Documents/custom_setup/custom-hyprland-dotfiles
chmod +x reset-dotfiles.sh
./reset-dotfiles.sh
```
This will backup your current broken config and allow you to start fresh.

---

## 👤 Credits
Customized and Maintained by **peakFlava**.
🚀 Happy Hyprland-ing!
