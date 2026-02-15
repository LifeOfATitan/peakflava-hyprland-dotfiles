# Waybar Transparency Toggle

## What Was Changed

Your Waybar bar background is now **transparent**, allowing your wallpaper to show through (with blur effect) while keeping all modules with their colored backgrounds.

### Changes Made:

1. **Current CSS Updated**: Added transparent background rule to `~/.config/waybar/style.css`
2. **Theme Switcher Updated**: Modified `~/.config/hypr/scripts/theme-switcher.sh` to include transparent background in CSS generation
3. **Backup Created**: Original opaque CSS saved to `~/.config/waybar/style.css.opaque-backup`
4. **Toggle Script Created**: Easy switching between transparent and opaque modes

## How to Use

### Check Current Status
```bash
~/.config/hypr/scripts/waybar-transparency-toggle.sh
```

### Switch to Transparent Mode
```bash
~/.config/hypr/scripts/waybar-transparency-toggle.sh --transparent
# or
~/.config/hypr/scripts/waybar-transparency-toggle.sh --light
```

### Switch Back to Opaque Mode
```bash
~/.config/hypr/scripts/waybar-transparency-toggle.sh --opaque
# or
~/.config/hypr/scripts/waybar-transparency-toggle.sh --dark
```

## What You'll See

### Transparent Mode (Current)
- ✅ Wallpaper shows through the bar (with blur effect)
- ✅ All modules keep their colored backgrounds
- ✅ Clean, modern look

### Opaque Mode (Original)
- ❌ Wallpaper is blocked by solid background
- ✅ All modules keep their colored backgrounds
- ✅ Traditional bar appearance

## Files Modified

1. `~/.config/waybar/style.css` - Current Waybar CSS
2. `~/.config/waybar/style.css.opaque-backup` - Backup of original opaque CSS
3. `~/.config/hypr/scripts/theme-switcher.sh` - Updated to generate transparent CSS
4. `~/.config/hypr/scripts/waybar-transparency-toggle.sh` - Toggle script

## If You Don't Like It

Run this command to go back to opaque mode:
```bash
~/.config/hypr/scripts/waybar-transparency-toggle.sh --opaque
```

This will restore your original opaque background from the backup file.

## Permanent Fix

The theme switcher has been updated, so any time you switch themes (including wallpaper-based Pywal), the transparent background will be maintained. You won't need to re-apply transparency manually.
