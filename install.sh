#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

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

for i in {1..20}; do
    rand_string=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w $(tput cols) | head -n 1)
    if (( i % 3 == 0 )); then
        echo -e "${WHITE}${rand_string:0:10}${GREEN}${rand_string:10}"
    else
        echo -e "${DARK_GREEN}${rand_string}"
    fi
    sleep 0.03
done

clear

echo -e "${GREEN}========================================================================${NC}"
echo -e "${WHITE}                    WELCOME TO THE MATRIX OS                            ${NC}"
echo -e "${GREEN}========================================================================${NC}"
echo ""
echo -e "> SECURE UPLINK ESTABLISHED."
echo -e "> INITIATING SETUP..."
echo ""

# --- CHECK FOR SUDO ACCESS PROPERLY ---
echo -e "${WHITE}[INFO] Checking for administrator privileges...${NC}"
if ! sudo -v; then
    echo -e "${RED}[FATAL] Administrator privileges are required to install dependencies.${NC}"
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
echo -e "> INSTALLING REQUIRED DEPENDENCIES..."

# --- INSTALL SYSTEM DEPENDENCIES ---
if [[ "$OS" =~ ^(ubuntu|debian|kali|linuxmint)$ ]]; then
    sudo apt-get update -y
    sudo apt-get install -y nmap tcpdump wget unzip curl libgl1-mesa-glx libxcb-cursor0 megatools
elif [[ "$OS" =~ ^(steamos|arch|manjaro)$ ]]; then
    echo -e "${DARK_GREEN}> Unlocking Arch/SteamOS read-only filesystem...${NC}"
    sudo steamos-readonly disable || true
    
    if [ ! -f /etc/pacman.d/gnupg/pubring.gpg ]; then
        sudo pacman-key --init || true
        sudo pacman-key --populate archlinux holo || true
    fi
    
    sudo pacman -Sy --noconfirm nmap tcpdump wget unzip curl
    
    # Install megatools static binary if not present
    if ! command -v megatools &> /dev/null; then
        echo -e "${GREEN}> Installing megatools static binary...${NC}"
        wget -q https://megatools.megous.com/builds/builds/megatools-1.11.1.20230212-linux-x86_64.tar.gz -O /tmp/megatools.tar.gz
        tar -xzf /tmp/megatools.tar.gz -C /tmp/
        sudo cp /tmp/megatools-*/megatools /usr/local/bin/
        sudo cp /tmp/megatools-*/megadl /usr/local/bin/
        rm -rf /tmp/megatools*
    fi
elif [ "$OS" == "fedora" ]; then
    sudo dnf install -y nmap tcpdump wget unzip curl megatools
else
    echo -e "${RED}[WARNING] Unknown Architecture. Please manually install: nmap, tcpdump, unzip, megatools${NC}"
fi

# --- GRANT CAPABILITIES ---
echo -e "> CONFIGURING NETWORK CAPABILITIES..."
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap 2>/dev/null || true
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/tcpdump 2>/dev/null || true

# --- DOWNLOAD AND EXTRACT CORE ---
DOWNLOAD_URL="https://mega.nz/file/2LhBSRLQ#-DwZ8vn4P7O9Dj0rF5B9BN6C-6tXWEeD9Za7wtr3-Dk"
INSTALL_DIR="MatrixOS"

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}> DOWNLOADING MATRIX OS NEURAL CORE... (This may take a while for large files)${NC}"
    mkdir -p "$INSTALL_DIR"
    
    megadl "$DOWNLOAD_URL" --path .
    
    ARCHIVE_FILE=$(find . -maxdepth 1 -name "*.zip" -o -name "*.tar*" | head -n 1)
    
    if [ -n "$ARCHIVE_FILE" ]; then
        echo -e "> UNPACKING CORE BINARIES FROM $ARCHIVE_FILE..."
        unzip -q "$ARCHIVE_FILE" -d extracted_core 2>/dev/null || tar -xf "$ARCHIVE_FILE" -C extracted_core
        
        rsync -avq extracted_core/*/ "$INSTALL_DIR/" 2>/dev/null || cp -r extracted_core/*/* "$INSTALL_DIR/" 2>/dev/null || cp -r extracted_core/* "$INSTALL_DIR/"
        rm -rf extracted_core "$ARCHIVE_FILE"
    else
        echo -e "${RED}[ERROR] Could not locate the downloaded archive file.${NC}"
        exit 1
    fi
else
    echo -e "${DARK_GREEN}> Matrix OS Core directory already exists. Skipping download.${NC}"
fi

# --- SECURE AND LAUNCH ---
echo -e "${WHITE}> BOOTING MATRIX OS KERNEL...${NC}"
cd "$INSTALL_DIR"
chmod +x MatrixOS 2>/dev/null || true
chmod +x ollama_engine 2>/dev/null || true

if [ -f "./MatrixOS" ]; then
    clear
    ./MatrixOS
else
    echo -e "${RED}[ERROR] 'MatrixOS' executable not found in the installation directory.${NC}"
    exit 1
fi
