# ═══════════════════════════════════════════════════════════════════
# CUSTOM ZSH THEME - Deep Purple & Cyan
# Inspired by HyDE aesthetics
# ═══════════════════════════════════════════════════════════════════

# Color definitions
local purple='%F{141}'      # Purple
local cyan='%F{51}'         # Cyan
local blue='%F{75}'         # Light Blue
local green='%F{114}'       # Green
local yellow='%F{228}'      # Yellow
local red='%F{203}'         # Red
local white='%F{255}'       # White
local gray='%F{244}'        # Gray
local reset='%f'

# Prompt symbols
local prompt_symbol='❯'
local git_branch_symbol='󰘬'
local git_dirty_symbol='✗'
local git_clean_symbol='✓'
local dir_symbol='󰉋'
local user_symbol='󰀄'
local host_symbol='󰒋'
local time_symbol='󰥔'

# Git status function
function git_prompt_info() {
    local ref
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    
    local git_status
    git_status=$(command git status --porcelain 2> /dev/null)
    
    if [[ -n $git_status ]]; then
        echo " ${purple}${git_branch_symbol} ${cyan}${ref#refs/heads/} ${red}${git_dirty_symbol}${reset}"
    else
        echo " ${purple}${git_branch_symbol} ${cyan}${ref#refs/heads/} ${green}${git_clean_symbol}${reset}"
    fi
}

# Directory path function (shortened)
function prompt_dir() {
    echo "${purple}${dir_symbol} ${cyan}%3~${reset}"
}

# User and host function
function prompt_user_host() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo "${yellow}${user_symbol} %n ${gray}at ${yellow}${host_symbol} %m${reset}"
    else
        echo "${purple}${user_symbol} %n${reset}"
    fi
}

# Time function
function prompt_time() {
    echo "${gray}${time_symbol} %*${reset}"
}

# Command execution time
function preexec() {
    timer=$(($(date +%s%0N)/1000000))
}

function precmd() {
    if [ $timer ]; then
        local now=$(($(date +%s%0N)/1000000))
        local elapsed=$(($now-$timer))
        
        if [[ $elapsed -gt 1000 ]]; then
            local elapsed_seconds=$(($elapsed/1000))
            export RPROMPT="${gray}took ${yellow}${elapsed_seconds}s${reset}"
        else
            export RPROMPT=""
        fi
        unset timer
    fi
}

# Status code function
function prompt_status() {
    echo "%(?.${green}.${red})${prompt_symbol}${reset}"
}

# Virtual environment indicator
function prompt_virtualenv() {
    if [[ -n $VIRTUAL_ENV ]]; then
        echo "${blue}(${VIRTUAL_ENV:t})${reset} "
    fi
}

# Build the prompt
PROMPT='
╭─$(prompt_user_host) $(prompt_dir)$(git_prompt_info)
╰─$(prompt_virtualenv)$(prompt_status) '

# Right prompt with time
RPROMPT='$(prompt_time)'

# Continuation prompt
PROMPT2="${gray}${prompt_symbol}${prompt_symbol}${reset} "

# Selection prompt
PROMPT3="${gray}?${reset} "

# Execution trace prompt
PROMPT4="${gray}+${reset} "
