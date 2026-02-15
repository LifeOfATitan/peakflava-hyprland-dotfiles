#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# NVIDIA GPU INFORMATION SCRIPT
# Display NVIDIA GPU status and information
# ═══════════════════════════════════════════════════════════════════

# Colors
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  NVIDIA GPU Information"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

# Check if nvidia-smi is available
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${RED}Error: nvidia-smi not found${NC}"
    echo -e "${YELLOW}Make sure NVIDIA drivers are installed${NC}"
    exit 1
fi

# GPU Name
echo -e "${CYAN}GPU Model:${NC}"
nvidia-smi --query-gpu=name --format=csv,noheader
echo

# Driver Version
echo -e "${CYAN}Driver Version:${NC}"
nvidia-smi --query-gpu=driver_version --format=csv,noheader
echo

# CUDA Version
echo -e "${CYAN}CUDA Version:${NC}"
nvidia-smi | grep "CUDA Version" | awk '{print $9}'
echo

# GPU Usage
echo -e "${CYAN}GPU Utilization:${NC}"
nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader
echo

# Memory Usage
echo -e "${CYAN}Memory Usage:${NC}"
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
echo

# Temperature
echo -e "${CYAN}Temperature:${NC}"
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | awk '{print $1"°C"}'
echo

# Power Usage
echo -e "${CYAN}Power Usage:${NC}"
nvidia-smi --query-gpu=power.draw,power.limit --format=csv,noheader
echo

# Fan Speed
echo -e "${CYAN}Fan Speed:${NC}"
nvidia-smi --query-gpu=fan.speed --format=csv,noheader
echo

# Clock Speeds
echo -e "${CYAN}Clock Speeds:${NC}"
echo -e "  Graphics: $(nvidia-smi --query-gpu=clocks.gr --format=csv,noheader)"
echo -e "  Memory:   $(nvidia-smi --query-gpu=clocks.mem --format=csv,noheader)"
echo

# Check if GPU is being used by Hyprland
echo -e "${CYAN}Wayland/Hyprland Status:${NC}"
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo -e "${GREEN}✓ Running on Wayland${NC}"
else
    echo -e "${YELLOW}⚠ Not running on Wayland${NC}"
fi

if [ "$GBM_BACKEND" = "nvidia-drm" ]; then
    echo -e "${GREEN}✓ NVIDIA GBM backend enabled${NC}"
else
    echo -e "${YELLOW}⚠ NVIDIA GBM backend not set${NC}"
fi

if [ "$__GLX_VENDOR_LIBRARY_NAME" = "nvidia" ]; then
    echo -e "${GREEN}✓ NVIDIA GLX vendor set${NC}"
else
    echo -e "${YELLOW}⚠ NVIDIA GLX vendor not set${NC}"
fi
echo

# Running processes on GPU
echo -e "${CYAN}Processes using GPU:${NC}"
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}No processes currently using GPU${NC}"
fi
echo

# Full nvidia-smi output
echo -e "${CYAN}Full GPU Status:${NC}"
nvidia-smi

echo
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
