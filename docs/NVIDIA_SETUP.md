# 🚀 NVIDIA Optimization Guide

This setup is fully optimized for NVIDIA GPUs (especially ROG Strix users) using the latest `hyprland` environment variables and configs.

---

## 🛠️ Required Drivers
Ensure you have the following installed on your Arch system:
```bash
sudo pacman -S nvidia-dkms nvidia-utils egl-wayland libva-nvidia-driver
```

## 📝 Configuration Included
Your `hypr/nvidia.conf` already handles the heavy lifting:
- **No Hardware Cursors**: Fixed flickering issues.
- **Vulkan/OpenGL**: Enabled `nvidia_anti_flicker`.
- **Environment**: Optimized for EGL and Wayland stability.

## 🔋 Recommended Kernel Parameters
For the smoothest experience, add these to your bootloader (GRUB/Systemd-boot):
```bash
nvidia-drm.modeset=1
```

## 💡 Troubleshooting
If you experience "ghosting" or lag, ensure your initramfs is updated with the NVIDIA modules:
1. Edit `/etc/mkinitcpio.conf` and add: `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`
2. Run: `sudo mkinitcpio -P`

---
Created by **peakFlava**
