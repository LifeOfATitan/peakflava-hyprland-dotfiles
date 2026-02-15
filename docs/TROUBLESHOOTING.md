# 🛠️ Troubleshooting & Maintenance

A guide to keeping your **peakFlava** setup running smoothly.

---

## 🔄 The Reset Tool
If something goes wrong with your configuration, use the built-in recovery script:
```bash
./reset-dotfiles.sh
```
**This tool allows you to:**
1.  **Fresh Start**: Safely backup and remove your current configs to re-install from scratch.
2.  **Restore**: Choose from previous backups to revert changes instantly.

## 🖼️ Wallpaper Picker Slow?
If the picker takes more than a second to open, run the refresh command to rebuild the thumbnail cache:
```bash
~/.config/hypr/scripts/wallpaper-picker.sh --refresh
```

## 🎨 Theme Not Applying?
Ensure **Pywal** is installed. You can manually test it with:
```bash
wal -i /path/to/your/wallpaper.jpg
```
If that works, the Theme Switcher will too.

---
Created by **peakFlava**
