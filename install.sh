#!/bin/bash

# --- ANSI COLOR CODES ---
GREEN='\033[38;5;46m'
DARK_GREEN='\033[38;5;22m'
WHITE='\033[1;37m'
RED='\033[1;31m'
NC='\033[0m' 

clear

# --- THE MATRIX RAIN ANIMATION ---
echo -e "${GREEN}Waking up the local host...${NC}"
sleep 1

for i in {1..30}; do
    rand_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w $(tput cols) | head -n 1)
    if (( i % 3 == 0 )); then
        echo -e "${WHITE}${rand_string:0:10}${GREEN}${rand_string:10}"
    else
        echo -e "${DARK_GREEN}${rand_string}"
    fi
    sleep 0.05
done

clear

echo -e "${GREEN}========================================================================${NC}"
echo -e "${WHITE}                      MATRIX OS // TACTICAL SUBNET INSTALLER            ${NC}"
echo -e "${GREEN}========================================================================${NC}"
echo ""
echo -e "> SECURE UPLINK ESTABLISHED."
echo -e "> INITIATING SYSTEM OVERRIDE..."
echo ""

# --- NATIVE SUDO PASSWORD INTERCEPT ---
echo -e "${RED}[WARNING] ROOT PRIVILEGES REQUIRED TO BYPASS KERNEL SECURITY.${NC}"

# We use the official sudo command, but rewrite its prompt (-p) to match our theme.
# This guarantees keystrokes are hidden and the password works across all Linux systems.
if sudo -p "> ENTER ROOT CLEARANCE (Password will be hidden): " -v 2>/dev/null; then
    echo -e "${WHITE}[ AUTHENTICATION ACCEPTED ]${NC}"
else
    echo -e "${RED}[ FATAL ] CLEARANCE DENIED. INCORRECT PASSWORD.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}> SCANNING ARCHITECTURE...${NC}"

# --- DETECT THE LINUX OPERATING SYSTEM ---
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    OS="unknown"
fi

echo -e "> DETECTED OS: ${WHITE}$OS${NC}"
echo -e "> DOWNLOADING TACTICAL DEPENDENCIES..."

# --- INSTALL NATIVE SYSTEM DEPENDENCIES (WITH MEGATOOLS) ---
# Because we already authenticated sudo above, these will not ask for a password again.
if [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ] || [ "$OS" == "kali" ] || [ "$OS" == "linuxmint" ]; then
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get install -y nmap tcpdump wget unzip curl libgl1-mesa-glx libxcb-cursor0 megatools >/dev/null 2>&1
elif [ "$OS" == "steamos" ] || [ "$OS" == "arch" ] || [ "$OS" == "manjaro" ]; then
    echo -e "${DARK_GREEN}> Unlocking Arch/SteamOS read-only filesystem...${NC}"
    sudo steamos-readonly disable >/dev/null 2>&1
    sudo pacman-key --init >/dev/null 2>&1
    sudo pacman-key --populate archlinux holo >/dev/null 2>&1
    sudo pacman -Sy --noconfirm nmap tcpdump wget unzip curl megatools >/dev/null 2>&1
elif [ "$OS" == "fedora" ]; then
    sudo dnf install -y nmap tcpdump wget unzip curl megatools >/dev/null 2>&1
else
    echo -e "${RED}[WARNING] Unknown Architecture. Please manually install: nmap tcpdump unzip megatools${NC}"
fi

# --- GRANT RADAR CAPABILITIES ---
echo -e "> GRANTING DEEP-PACKET INSPECTION CAPABILITIES..."
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap >/dev/null 2>&1
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/tcpdump >/dev/null 2>&1

# --- DOWNLOAD THE MATRIX OS CORE BINARIES FROM MEGA ---
DOWNLOAD_URL="https://mega.nz/file/c7BGVCbB#OpkBkKCgJjv2LE6NQH7i5zutSk8X0kFD9-lxwaJKUIc"

if [ ! -d "MatrixOS" ]; then
    echo -e "${GREEN}> DOWNLOADING MATRIX OS NEURAL CORE FROM MEGA... (Standby, fetching 8.1GB payload)${NC}"
    
    # megadl handles the MEGA encryption and download
    megadl "$DOWNLOAD_URL"
    
    echo -e "> UNPACKING CORE BINARIES..."
    unzip -q MatrixOS.zip -d MatrixOS_Core
    mv MatrixOS_Core/*/* MatrixOS/ 2>/dev/null || mv MatrixOS_Core/* MatrixOS/
    rm -rf MatrixOS_Core MatrixOS.zip
else
    echo -e "${DARK_GREEN}> Matrix OS Core already exists. Skipping download.${NC}"
fi

# --- SECURE AND LAUNCH ---
echo -e "${WHITE}> BOOTING MATRIX OS KERNEL...${NC}"
cd MatrixOS
chmod +x MatrixOS
chmod +x ollama_engine 2>/dev/null

# Clear the screen one last time before the graphical UI pops up
clear
./MatrixOS
