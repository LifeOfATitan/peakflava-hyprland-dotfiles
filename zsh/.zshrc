# ═══════════════════════════════════════════════════════════════════
# ZSH CONFIGURATION
# Custom setup with Oh My Zsh
# ═══════════════════════════════════════════════════════════════════

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# ═══════════════════════════════════════════════════════════════════
# THEME
# ═══════════════════════════════════════════════════════════════════
# Copy custom-theme.zsh-theme to ~/.oh-my-zsh/custom/themes/
ZSH_THEME="custom-theme"

# ═══════════════════════════════════════════════════════════════════
# PLUGINS
# ═══════════════════════════════════════════════════════════════════
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    sudo
    command-not-found
    colored-man-pages
    extract
    web-search
    copypath
    copyfile
    copybuffer
    dirhistory
    history
)

# ═══════════════════════════════════════════════════════════════════
# OH MY ZSH SETTINGS
# ═══════════════════════════════════════════════════════════════════
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="false"
DISABLE_UPDATE_PROMPT="false"
export UPDATE_ZSH_DAYS=7
DISABLE_MAGIC_FUNCTIONS="false"
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"

# ═══════════════════════════════════════════════════════════════════
# HISTORY
# ═══════════════════════════════════════════════════════════════════
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# ═══════════════════════════════════════════════════════════════════
# SOURCE OH MY ZSH
# ═══════════════════════════════════════════════════════════════════
source $ZSH/oh-my-zsh.sh

# ═══════════════════════════════════════════════════════════════════
# USER CONFIGURATION
# ═══════════════════════════════════════════════════════════════════

# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ═══════════════════════════════════════════════════════════════════
# PATH
# ═══════════════════════════════════════════════════════════════════
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# ═══════════════════════════════════════════════════════════════════
# ALIASES
# ═══════════════════════════════════════════════════════════════════

# System
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias clean='sudo pacman -Sc'
alias orphans='sudo pacman -Rns $(pacman -Qtdq)'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias update-paru='paru -Sua'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# List files
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias l='eza -lah --icons --group-directories-first'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# System info
alias cpu='cat /proc/cpuinfo | grep "model name" | head -1'
alias mem='free -h'
alias disk='df -h'
alias temp='sensors'

# Hyprland
alias hypreload='hyprctl reload'
alias hyprkill='killall waybar && waybar &'

# Utilities
alias c='clear'
alias h='history'
alias j='jobs'
alias v='nvim'
alias vim='nvim'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias ps='procs'
alias top='btop'
alias du='dust'

# Quick config edits
alias zshconf='nvim ~/.zshrc'
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias waybarconf='nvim ~/.config/waybar/config.jsonc'
alias roficonf='nvim ~/.config/rofi/config.rasi'
alias openconf='nvim ~/.config/opencode/opencode.json'
alias keybindconf="nvim ~/.config/hypr/keybinds.conf"
alias tmuxconf="nvim ~/.config/tmux/tmux.conf"

# Suffix aliases to open files
alias -s {pdf,jpg,png}=open
alias -s {py,js,ts,lua,json,md,txt,conf,yml,yaml}=nvim

#open nvim folder to edit configs 
alias nvimconf='cd ~/.config/nvim && nvim .'
# ═══════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════

# FUNCTIONS
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

#list director after CD in in 
cd(){
builtin cd "$@" && ls
}

# Extract any archive with progress bar and optional destination
extract() {
    local src="$1"
    local dest="${2:-.}"

    if [[ -z "$src" ]]; then
        echo "Usage: extract <file> [destination_dir]"
        return 1
    fi

    if [[ ! -f "$src" ]]; then
        echo "Error: '$src' is not a valid file"
        return 1
    fi

    # Create destination if it doesn't exist
    [[ "$dest" != "." ]] && mkdir -p "$dest"

    # Check for pv (Pipe Viewer)
    local has_pv=$(command -v pv)

    case "$src" in
        *.tar.gz|*.tgz|*.tar.xz|*.tar.bz2|*.tar)
            if [[ -n "$has_pv" ]]; then
                pv "$src" | tar -x -C "$dest" -f -
            else
                tar -xvf "$src" -C "$dest"
            fi
            ;;
        *.zip)
            unzip "$src" -d "$dest"
            ;;
        *.7z)
            7z x "$src" -o"$dest"
            ;;
        *.rar)
            unrar x "$src" "$dest"
            ;;
        *.gz)
            if [[ -n "$has_pv" ]]; then
                pv "$src" | gunzip > "$dest/${src%.gz}"
            else
                gunzip -c "$src" > "$dest/${src%.gz}"
            fi
            ;;
        *.bz2)
            if [[ -n "$has_pv" ]]; then
                pv "$src" | bunzip2 > "$dest/${src%.bz2}"
            else
                bunzip2 -c "$src" > "$dest/${src%.bz2}"
            fi
            ;;
        *)
            echo "Error: '$src' format not supported"
            return 1
            ;;
    esac
}

# Usage: backup [-z] <source> [destination]
# Example: backup myfile.txt                 -> creates ./myfile.txt.backup-20260220
# Example: backup -z myfolder /mnt/backups   -> creates /mnt/backups/myfolder.backup-20260220.tar.gz
backup() {
    local compress=false
    if [[ "$1" == "-z" ]]; then
        compress=true; shift
    fi

    local src="$1"
    local dest_dir="${2:-.}"
    [[ -z "$src" ]] && { echo "Usage: backup [-z] <src> [dest_dir]"; return 1; }
    [[ ! -e "$src" ]] && { echo "Error: '$src' not found"; return 1; }

    local timestamp=$(date +%Y%m%d)
    local filename=$(basename "$src")
    local base_backup="${dest_dir}/${filename}.backup-${timestamp}"
    local ext=""
    [[ "$compress" == true ]] && ext=".tar.gz"

    # Smart Counter: Find a unique name for today
    local final_backup="${base_backup}${ext}"
    local counter=1
    while [[ -e "$final_backup" ]]; do
        final_backup="${base_backup}-${counter}${ext}"
        ((counter++))
    done

    # Perform Backup with Progress
    if [[ "$compress" == true ]]; then
        echo "Compressing and backing up '$src' to '$final_backup'..."
        local size=$(du -sb "$src" | awk '{print $1}')
        tar -cf - "$src" | pv -s "$size" | gzip > "$final_backup"
    else
        echo "Backing up '$src' to '$final_backup'..."
        # Using rsync for better progress bar than 'cp'
        rsync -ra --info=progress2 "$src" "$final_backup"
    fi

    # Cleanup: Delete backups of this specific file/dir in the destination folder older than 30 days
    find "$dest_dir" -maxdepth 1 -name "${filename}.backup-*" -mtime +30 -exec rm -rf {} +
}

# Search and kill process
pskill() {
    ps aux | grep -v grep | grep -i -e "$1" | awk '{print $2}' | xargs sudo kill -9
}

# ═══════════════════════════════════════════════════════════════════
# PLUGIN CONFIGURATIONS
# ═══════════════════════════════════════════════════════════════════

# zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ═══════════════════════════════════════════════════════════════════
# KEYBINDINGS
# ═══════════════════════════════════════════════════════════════════
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# ═══════════════════════════════════════════════════════════════════
# STARTUP
# ═══════════════════════════════════════════════════════════════════

# Display system info on startup (optional)
# fastfetch

# Welcome message
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                What We Finna Do Today Pimpin              ║"
echo "╚═══════════════════════════════════════════════════════════╝"

eval $(thefuck --alias)

nvim() {
    # Skip resize if inside tmux
    if [ -n "$TMUX" ]; then
        command nvim "$@"
        return
    fi

    # Resize to Neovim size and center
    hyprctl --batch "dispatch resizewindowpixel exact 90% 80%,active; dispatch centerwindow" > /dev/null 2>&1
        
    # Run the actual nvim command with all passed arguments
    command nvim "$@"
        
    # Restore to your regular 1200x800 size and center
    hyprctl --batch "dispatch resizewindowpixel exact 1200 800,active; dispatch centerwindow" > /dev/null 2>&1
}

opencode (){
    # Skip resize if inside tmux
    if [ -n "$TMUX" ]; then
        command opencode "$@"
        return
    fi

    # Resize opencode to bigger window
    hyprctl --batch "dispatch resizewindowpixel exact 90% 80%,active; dispatch centerwindow" > /dev/null 2>&1

    # Run the actual opencode command with all passed arguments
    command opencode "$@"

    # Restore to regular sized window
    hyprctl --batch "dispatch resizewindowpixel exact 1200 800,active; dispatch centerwindow" > /dev/null 2>&1
}

tmux (){
    #Resize after open 
    hyprctl --batch "dispatch resizewindowpixel exact 90% 90%,active; dispatch centerwindow" > /dev/null 2>&1

    # open tmux with all arguments
    command tmux "$@"

    # Restore window to OG size
    hyprctl --batch "dispatch resizewindowpixel exact 1200 800,active; dispatch centerwindow" > /dev/null 2>&1

}

# opencode
export PATH=/home/amadeus/.opencode/bin:$PATH
