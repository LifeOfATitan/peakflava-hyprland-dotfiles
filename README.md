# 💜 peakFlava's Custom Hyprland Dotfiles

A high-performance, visually polished, and fully customized Hyprland environment for Arch Linux. Built with a unique **Deep Purple & Cyan** aesthetic and featuring a smart, dynamic theming engine.

---

## 🎨 Features
- **Dynamic Theme Switcher**: Perfectly sync your entire UI with any wallpaper using Pywal.
- **Video Wallpaper Engine**: Native support for live wallpapers via `mpvpaper`.
- **Intelligent Rofi**: A custom, centered 3-column grid for wallpaper selection.
- **Dashboards**: Integrated BTOP system monitoring that inherits your current theme.
- **Orbit Connection Manager**: A native, glassmorphism-styled manager for WiFi and Bluetooth.
- **Productivity Boost**: Custom auto-resizing functions for Neovim, Tmux, and more.

## 📸 Screenshots

### Desktop & Overview
![Desktop](./screenshots/desktop-overview.png)
![Desktop](./screenshots/desktop-overview2.png)
![Desktop](./screenshots/desktop-overview3.png)

### Status Bar
![Waybar](./screenshots/waybar-status-bar.png)
![Waybar](./screenshots/waybar-status-bar2.png)

### Launchers & Pickers
![Rofi](./screenshots/rofi-app-launcher.png)
![Wallpaper Picker](./screenshots/wallpaper-picker.png)
![Theme Switcher](./screenshots/theme-switcher.png)
![Keybinds](./screenshots/keybinds.png)

### Terminal
![Kitty](./screenshots/kitty-terminal.png)

### System
![Lock Screen](./screenshots/wlogout-lock-screen.png)
![Lock Screen](./screenshots/wlogout-lock-screen2.png)
![Notification](./screenshots/dunst-notification.png)

### Network & Connections
![Orbit](./screenshots/orbit_demo.gif)
*For full documentation and advanced usage, visit the [Orbit Repository](https://github.com/LifeOfATitan/orbit).*

---

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/peakFlava/custom-hyprland-dotfiles.git
cd custom-hyprland-dotfiles
```

### 2. Run the installer
```bash
chmod +x install.sh
./install.sh
```

---

## 📚 Documentation
Learn how to get the most out of this setup:

- **[🎥 Video Wallpapers](docs/VIDEO_WALLPAPERS.md)** - Where to find them and how to use them.
- **[🎨 Theme Switcher](docs/THEME_SWITCHER.md)** - Managing your dynamic palettes and favorites.
- **[⌨️ Keybindings](docs/KEYBINDINGS.md)** - Every shortcut you need to know.
- **[🚀 NVIDIA Setup](docs/NVIDIA_SETUP.md)** - Optimization notes for NVIDIA GPU users.
- **[🛠️ Troubleshooting](docs/TROUBLESHOOTING.md)** - Maintenance and recovery tips.

---

## 👤 Author
Developed and maintained by **peakFlava**.

## 📜 License
This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🆙 Upgrading

If you have already installed these dotfiles and want to update to the latest version, follow these steps:

1. **Pull the latest changes:**
   ```bash
   git pull origin main
   ```

2. **Install the new dependency:**
   `awww` is now the default wallpaper manager. Install it via your AUR helper:
   ```bash
   yay -S awww
   ```

3. **Re-run the installation script:**
   This will update your configuration files and scripts to work with `awww`:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

4. **Cleanup:**
   You can safely remove `swww` if you no longer use it:
   ```bash
   sudo pacman -Rns swww
   ```

5. **Restart Hyprland:**
   Log out and log back in, or restart Hyprland for the `awww-daemon` to initialize.
