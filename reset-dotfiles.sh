#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# peakFlava's DOTFILES RESET & RESTORE SCRIPT
# Safely removes existing configurations and provides restore options
# ═══════════════════════════════════════════════════════════════════

set -e

# Colors
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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
    print_header "Backing up all existing configurations"
    
    BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    print_info "Creating comprehensive backup in $BACKUP_DIR..."
    
    # List of configuration directories and files
    config_items=(
        ".config/hypr"
        ".config/waybar"
        ".config/rofi"
        ".config/kitty"
        ".config/dunst"
        ".config/wlogout"
        ".config/nvim"
        ".config/tmux"
        ".config/btop"
        ".config/zsh"
        ".zshrc"
        ".bashrc"
        ".bash_profile"
        ".Xresources"
        ".tmux.conf"
    )
    
    for item in "${config_items[@]}"; do
        if [ -e "$HOME/$item" ]; then
            print_info "Backing up $item..."
            mkdir -p "$BACKUP_DIR/$(dirname "$item")"
            cp -r "$HOME/$item" "$BACKUP_DIR/$item"
        fi
    done
    
    print_success "Backup completed successfully"
}

# ═══════════════════════════════════════════════════════════════════
# REMOVE CONFIGURATION FILES
# ═══════════════════════════════════════════════════════════════════
remove_configs() {
    print_header "Removing current configuration files"
    
    # Directories and files to remove
    items_to_remove=(
        ".config/hypr"
        ".config/waybar"
        ".config/rofi"
        ".config/kitty"
        ".config/dunst"
        ".config/wlogout"
        ".config/nvim"
        ".config/tmux"
        ".config/btop"
        ".zshrc"
        ".tmux.conf"
        ".cache/wal"
        ".cache/hypr_colors.conf"
        ".cache/waybar_colors.css"
        ".cache/rofi_colors.rasi"
        ".cache/blurred_wallpaper.png"
    )
    
    for item in "${items_to_remove[@]}"; do
        if [ -e "$HOME/$item" ]; then
            print_info "Removing $HOME/$item..."
            rm -rf "$HOME/$item"
        fi
    done
    
    print_success "Configurations removed"
}

# ═══════════════════════════════════════════════════════════════════
# RESTORE BACKUP
# ═══════════════════════════════════════════════════════════════════
restore_backup() {
    print_header "Restore Configuration Backup"
    
    # Find all backup directories
    backups=($(ls -d $HOME/dotfiles-backup-* 2>/dev/null || true))
    
    if [ ${#backups[@]} -eq 0 ]; then
        print_error "No backup directories found in $HOME"
        return
    fi
    
    echo -e "${CYAN}Available backups:${NC}"
    for i in "${!backups[@]}"; do
        echo -e "  ${PURPLE}[$i]${NC} $(basename "${backups[$i]}")"
    done
    echo
    
    read -p "Enter the number of the backup to restore (or 'q' to quit): " choice
    
    if [[ "$choice" == "q" ]]; then
        return
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt "${#backups[@]}" ]; then
        SELECTED_BACKUP="${backups[$choice]}"
        print_info "Restoring from $SELECTED_BACKUP..."
        
        # Confirm before overwriting
        print_warning "This will overwrite your current configurations with the backup."
        read -p "Are you sure? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Restore cancelled"
            return
        fi
        
        # Perform restore
        cp -rv "$SELECTED_BACKUP/." "$HOME/"
        
        print_success "Restore completed successfully!"
        print_info "You may need to restart your session for changes to take effect."
    else
        print_error "Invalid selection"
    fi
}

# ═══════════════════════════════════════════════════════════════════
# MAIN MENU
# ═══════════════════════════════════════════════════════════════════
main() {
    clear
    print_header "peakFlava's Dotfiles Manager"
    echo -e "  ${PURPLE}[1]${NC} Reset & Cleanup (Fresh Start)"
    echo -e "  ${PURPLE}[2]${NC} Restore from Backup"
    echo -e "  ${PURPLE}[3]${NC} Exit"
    echo
    read -p "Select an option: " option
    
    case $option in
        1)
            print_warning "This will PERMANENTLY REMOVE your current configurations."
            print_warning "A comprehensive backup will be created first."
            read -p "Proceed? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                backup_configs
                remove_configs
                print_success "Reset complete! Run ./install.sh to install new dotfiles."
            fi
            ;;
        2)
            restore_backup
            ;;
        3)
            exit 0
            ;;
        *)
            print_error "Invalid option"
            sleep 2
            main
            ;;
    esac
}

main
