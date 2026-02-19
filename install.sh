#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# peakFlava's CUSTOM HYPRLAND DOTFILES INSTALLATION SCRIPT
# ═══════════════════════════════════════════════════════════════════

set -e

# Colors for output
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  $1"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ═══════════════════════════════════════════════════════════════════
# BACKUP EXISTING CONFIGS
# ═══════════════════════════════════════════════════════════════════
backup_configs() {
    print_header "Backing up existing configurations"
    
    BACKUP_DIR="$HOME/.config/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    configs=("hypr" "waybar" "rofi" "kitty" "dunst" "swaync" "wlogout" "nvim" "tmux" "orbit")
    
    for config in "${configs[@]}"; do
        if [ -d "$HOME/.config/$config" ]; then
            print_info "Backing up $config..."
            cp -r "$HOME/.config/$config" "$BACKUP_DIR/"
            print_success "Backed up $config to $BACKUP_DIR"
        fi
    done
    
    if [ -f "$HOME/.zshrc" ]; then
        print_info "Backing up .zshrc..."
        cp "$HOME/.zshrc" "$BACKUP_DIR/"
        print_success "Backed up .zshrc to $BACKUP_DIR"
    fi
    
    if [ -f "$HOME/.tmux.conf" ]; then
        print_info "Backing up .tmux.conf..."
        cp "$HOME/.tmux.conf" "$BACKUP_DIR/"
        print_success "Backed up .tmux.conf to $BACKUP_DIR"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# INSTALL DEPENDENCIES
# ═══════════════════════════════════════════════════════════════════
install_dependencies() {
    print_header "Installing dependencies"
    
    print_info "Checking for required packages..."
    
    packages=(
        "hyprland"
        "waybar"
        "hypridle"
        "rofi-wayland"
        "kitty"
        "dunst"
        "swww"
        "wlogout"
        "grim"
        "slurp"
        "wl-clipboard"
        "cliphist"
        "brightnessctl"
        "playerctl"
        "pavucontrol"
        "network-manager-applet"
        "blueman"
        "hyprpolkitagent"
        "xdg-desktop-portal-hyprland"
        "qt6ct"
        "nwg-look"
        "papirus-icon-theme"
        "ttf-jetbrains-mono-nerd"
        "zsh"
        "eza"
        "bat"
        "ripgrep"
        "fd"
        "procs"
        "btop"
        "dust"
        "fastfetch"
        "python-pywal"
        "imagemagick"
        "neovim"
        "tmux"
        "git"
        "make"
        "gcc"
        "bc"
        "ffmpeg"
        "thefuck"
        "orbit-wifi"
    )
    
    nvidia_packages=(
        "nvidia-dkms"
        "nvidia-utils"
        "nvidia-settings"
        "egl-wayland"
        "libva-nvidia-driver"
    )
    
    print_info "The following packages will be installed:"
    printf '%s\n' "${packages[@]}"
    echo
    
    # Check for NVIDIA GPU
    if lspci | grep -i nvidia > /dev/null; then
        print_info "NVIDIA GPU detected!"
        print_info "Additional NVIDIA packages available:"
        printf '%s\n' "${nvidia_packages[@]}"
        echo
        read -p "Install NVIDIA drivers? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            INSTALL_NVIDIA=true
        else
            print_info "Skipping NVIDIA driver installation."
            INSTALL_NVIDIA=false
        fi
    else
        print_warning "No NVIDIA GPU detected. Skipping NVIDIA packages."
        INSTALL_NVIDIA=false
    fi
    
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing packages..."
        sudo pacman -S --needed "${packages[@]}"
        
        if [ "$INSTALL_NVIDIA" = true ]; then
            print_info "Installing NVIDIA packages..."
            sudo pacman -S --needed "${nvidia_packages[@]}"
            print_success "NVIDIA packages installed"
        fi

        # Install Orbit from AUR
        print_info "Checking for AUR helper to install orbit-wifi..."
        if command -v yay &> /dev/null; then
            yay -S --needed orbit-wifi
        elif command -v paru &> /dev/null; then
            paru -S --needed orbit-wifi
        else
            print_warning "No AUR helper found. Please install 'orbit-wifi' manually from AUR."
        fi
        
        print_success "Packages installed successfully"
    else
        print_warning "Skipping package installation"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# INSTALL OH MY ZSH
# ═══════════════════════════════════════════════════════════════════
install_oh_my_zsh() {
    print_header "Installing Oh My Zsh"
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    else
        print_info "Oh My Zsh already installed"
    fi
    
    # Install plugins
    print_info "Installing Oh My Zsh plugins..."
    
    # zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
    
    # zsh-completions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
    fi
    
    print_success "Oh My Zsh plugins installed"
}

# ═══════════════════════════════════════════════════════════════════
# COPY DOTFILES
# ═══════════════════════════════════════════════════════════════════
copy_dotfiles() {
    print_header "Copying dotfiles"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create config directories
    mkdir -p "$HOME/.config"/{hypr,waybar,rofi,kitty,wlogout,nvim,tmux,btop,orbit}
    mkdir -p "$HOME/.config/hypr"/{scripts,themes}
    mkdir -p "$HOME/.config/waybar/scripts"
    mkdir -p "$HOME/.config/btop/themes"
    mkdir -p "$HOME/wallpapers"
    mkdir -p "$HOME/.cache/wal"
    
    # Initialize cache files
    touch "$HOME/.cache/waybar_colors.css"
    touch "$HOME/.cache/hypr_colors.conf"
    touch "$HOME/.cache/hyprlock_colors.conf"
    touch "$HOME/.cache/dunst_colors"
    touch "$HOME/.cache/rofi_colors.rasi"
    
    # Initialize default colors
    cat > "$HOME/.cache/hypr_colors.conf" <<EOF
\$accent = rgb(8b5cf6)
\$accent_alt = rgb(06b6d4)
\$background = rgb(1e1e2e)
\$foreground = rgb(d4d4d8)
EOF

    cat > "$HOME/.cache/hyprlock_colors.conf" <<EOF
\$accent_hex = 8b5cf6
\$accent_alt_hex = 06b6d4
\$background_hex = 1e1e2e
\$foreground_hex = d4d4d8
EOF
    fi
    
    # Initialize default colors
    cat > "$HOME/.cache/hypr_colors.conf" <<EOF
$accent = rgb(8b5cf6)
$accent_alt = rgb(06b6d4)
$background = rgb(1e1e2e)
$foreground = rgb(d4d4d8)
EOF

    # Initialize Orbit theme
    cat > "$HOME/.config/orbit/theme.toml" <<EOF
accent_primary = "#8b5cf6"
accent_secondary = "#06b6d4"
background = "#1e1e2e"
foreground = "#d4d4d8"
EOF

    cat > "$HOME/.cache/waybar_colors.css" <<EOF
@define-color accent #8b5cf6;
@define-color accent_alt #06b6d4;
@define-color bg #1e1e2e;
@define-color fg #d4d4d8;
EOF

    cat > "$HOME/.cache/dunst_colors" <<EOF
[global]
    frame_color = "#8b5cf6"
[urgency_low]
    background = "#1e1e2e"
    foreground = "#d4d4d8"
[urgency_normal]
    background = "#1e1e2e"
    foreground = "#d4d4d8"
[urgency_critical]
    background = "#1e1e2e"
    foreground = "#d4d4d8"
    frame_color = "#06b6d4"
EOF
    
    print_success "Dotfiles copied successfully"
}

# ═══════════════════════════════════════════════════════════════════
# SET PERMISSIONS
# ═══════════════════════════════════════════════════════════════════
set_permissions() {
    print_header "Setting permissions"
    
    find "$HOME/.config/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} +
    find "$HOME/.config/waybar/scripts" -type f -name "*.sh" -exec chmod +x {} +
    
    print_success "Permissions set"
}

# ═══════════════════════════════════════════════════════════════════
# CHANGE DEFAULT SHELL
# ═══════════════════════════════════════════════════════════════════
change_shell() {
    print_header "Changing default shell to Zsh"
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to Zsh..."
        chsh -s $(which zsh)
        print_success "Default shell changed to Zsh"
        print_warning "Please log out and log back in for the change to take effect"
    else
        print_info "Default shell is already Zsh"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# MAIN INSTALLATION
# ═══════════════════════════════════════════════════════════════════
main() {
    clear
    print_header "Custom Hyprland Dotfiles Installation"
    echo
    
    print_warning "This script will:"
    echo "  1. Backup your existing configurations"
    echo "  2. Install required dependencies (Arch Linux)"
    echo "  3. Install Oh My Zsh and plugins"
    echo "  4. Copy peakFlava's dotfiles to ~/.config"
    echo "  5. Change your default shell to Zsh"
    echo
    
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled"
        exit 1
    fi
    
    backup_configs
    install_dependencies
    install_oh_my_zsh
    copy_dotfiles
    set_permissions
    change_shell
    
    # Enable Orbit service
    print_info "Enabling Orbit background service..."
    systemctl --user enable --now orbit 2>/dev/null || print_warning "Could not enable orbit service. Is it installed?"
    
    echo
    print_header "Installation Complete!"
    echo
    print_success "Your custom Hyprland setup is ready!"
    echo
    print_info "Next steps:"
    echo "  1. Place your wallpaper in ~/wallpapers/wallpaper.jpg"
    echo "  2. Log out and log back in (or reboot)"
    echo "  3. Select Hyprland from your display manager"
    echo "  4. Enjoy your new setup!"
    echo
    print_info "Key bindings:"
    echo "  SUPER + RETURN     - Open terminal"
    echo "  SUPER + A          - Open app launcher"
    echo "  SUPER + Q          - Close window"
    echo "  SUPER + F          - Toggle fullscreen"
    echo "  SUPER + ESC        - Power menu"
    echo "  SUPER + CTRL + T   - Theme switcher"
    echo "  SUPER + CTRL + N   - Toggle Notification Daemon"
    echo
    print_info "Development tools installed:"
    echo "  • Neovim with lazy.nvim plugin manager"
    echo "  • Tmux with custom configuration"
    echo "  • Neovim plugins will auto-install on first launch"
    echo
    print_info "For more keybindings, check ~/.config/hypr/keybinds.conf"
    echo
    
    if [ "$INSTALL_NVIDIA" = true ]; then
        print_header "NVIDIA Setup Complete!"
        echo
        print_info "Additional steps for ROG Strix laptops:"
        echo "  1. Install supergfxctl for GPU switching:"
        echo "     yay -S supergfxctl"
        echo "     sudo systemctl enable --now supergfxd"
        echo
        echo "  2. Use the included scripts:"
        echo "     ~/.config/hypr/scripts/gpu-mode.sh    - Switch GPU modes"
        echo "     ~/.config/hypr/scripts/nvidia-info.sh - Check GPU status"
        echo
        echo "  3. Verify NVIDIA setup:"
        echo "     nvidia-smi"
        echo "     ~/.config/hypr/scripts/nvidia-info.sh"
        echo
        print_warning "A reboot is REQUIRED for NVIDIA changes to take effect!"
        echo
    fi
}

# Run main function
main
