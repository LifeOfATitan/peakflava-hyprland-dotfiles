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
alias zshconfig='nvim ~/.zshrc'
alias hyprconfig='nvim ~/.config/hypr/hyprland.conf'
alias waybarconfig='nvim ~/.config/waybar/config.jsonc'
alias roficonfig='nvim ~/.config/rofi/config.rasi'

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

# Extract any archive
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick backup
backup() {
    cp "$1"{,.backup-$(date +%Y%m%d-%H%M%S)}
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
    # Resize to Neovim size and center
    hyprctl --batch "dispatch resizewindowpixel exact 90% 80%,active; dispatch centerwindow" > /dev/null 2>&1
        
    # Run the actual nvim command with all passed arguments
    command nvim "$@"
        
    # Restore to your regular 1200x800 size and center
    hyprctl --batch "dispatch resizewindowpixel exact 1200 800,active; dispatch centerwindow" > /dev/null 2>&1
}

opencode (){
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
export PATH="$HOME/flutter/bin:$PATH"
