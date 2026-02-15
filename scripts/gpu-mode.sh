#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
# GPU MODE SWITCHER FOR ROG STRIX LAPTOPS
# Switches between Integrated, Hybrid, and NVIDIA modes
# ═══════════════════════════════════════════════════════════════════

# Colors
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if supergfxctl is installed
if ! command -v supergfxctl &> /dev/null; then
    echo -e "${RED}Error: supergfxctl is not installed${NC}"
    echo -e "${YELLOW}Install with: yay -S supergfxctl${NC}"
    exit 1
fi

# Get current mode
CURRENT_MODE=$(supergfxctl -g)

echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  GPU Mode Switcher for ROG Strix"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}Current Mode:${NC} ${GREEN}${CURRENT_MODE}${NC}"
echo

# Show menu
echo -e "${CYAN}Available Modes:${NC}"
echo -e "  ${PURPLE}1)${NC} Integrated  - Intel GPU only (Best battery life)"
echo -e "  ${PURPLE}2)${NC} Hybrid      - Intel + NVIDIA on demand"
echo -e "  ${PURPLE}3)${NC} NVIDIA      - NVIDIA GPU only (Best performance)"
echo -e "  ${PURPLE}4)${NC} Compute     - NVIDIA for compute tasks"
echo -e "  ${PURPLE}5)${NC} Vfio        - NVIDIA for VM passthrough"
echo -e "  ${PURPLE}q)${NC} Quit"
echo

read -p "Select mode: " choice

case $choice in
    1)
        echo -e "${YELLOW}Switching to Integrated mode...${NC}"
        supergfxctl -m Integrated
        ;;
    2)
        echo -e "${YELLOW}Switching to Hybrid mode...${NC}"
        supergfxctl -m Hybrid
        ;;
    3)
        echo -e "${YELLOW}Switching to NVIDIA mode...${NC}"
        supergfxctl -m AsusMuxDgpu
        ;;
    4)
        echo -e "${YELLOW}Switching to Compute mode...${NC}"
        supergfxctl -m AsusEgpu
        ;;
    5)
        echo -e "${YELLOW}Switching to Vfio mode...${NC}"
        supergfxctl -m Vfio
        ;;
    q|Q)
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo
echo -e "${GREEN}Mode changed successfully!${NC}"
echo -e "${YELLOW}Note: A reboot or re-login may be required for changes to take effect${NC}"
echo

read -p "Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${PURPLE}Rebooting...${NC}"
    systemctl reboot
fi
