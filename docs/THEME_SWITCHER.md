# 🎨 Dynamic Theme Switcher

Your environment features a custom-built, dynamic theming system that synchronizes your entire UI with your wallpaper.

---

## 🚀 Usage
Press **`SUPER + CTRL + T`** to open the Theme Menu.

### 🌟 Features
1.  **Wallpaper-based Theme**: 
    *   Uses **Pywal** to extract a color palette from your current wallpaper (including video frames!).
    *   Instantly updates Waybar, Rofi, Kitty, Dunst, and BTOP.
2.  **Favorites Management**:
    *   **Save**: Found a color combination you love? Save it with a custom name.
    *   **Manage**: Quickly switch between your saved favorites, rename them, or delete old ones.
3.  **Default Theme**: Instantly revert to the signature **peakFlava** Purple & Cyan palette.

## 🌈 How it Works
The switcher generates color cache files in `~/.cache/`:
- `hypr_colors.conf`: Native Hyprland variables.
- `waybar_colors.css`: Dynamic CSS for your status bar.
- `rofi_colors.rasi`: Synchronized launcher colors.
- `peakFlava.theme`: Real-time BTOP color mapping.

## 💡 Customization
If you want to manually tweak how colors are applied, check the `hypr/scripts/theme-switcher.sh` script. It is heavily commented and easy to modify.

---
Created by **peakFlava**
