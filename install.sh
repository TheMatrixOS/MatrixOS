#!/bin/bash

echo "=== MatrixOS Automated Installer ==="

# 1. Check for dependencies (zenity, unzip, megatools)
if ! command -v zenity &> /dev/null || ! command -v megadl &> /dev/null; then
    echo "Installing required dependencies..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install zenity unzip megatools -y
    elif command -v dnf &> /dev/null; then
        sudo dnf install zenity unzip megatools -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -S zenity unzip megatools --noconfirm
    fi
fi

# 2. Open GUI folder picker for installation path
DEST_DIR=$(zenity --file-selection --directory --title="Select Where to Install MatrixOS")

if [ -z "$DEST_DIR" ]; then
    echo "Installation cancelled by user."
    exit 1
fi

echo "Installing to: $DEST_DIR"
cd "$DEST_DIR" || exit 1

# 3. Download MatrixOS from MEGA link
MEGA_URL="https://mega.nz/file/2LhBSRLQ#-DwZ8vn4P7O9Dj0rF5B9BN6C-6tXWEeD9Za7wtr3-Dk"
echo "Downloading MatrixOS package..."
megadl "$MEGA_URL"

# 4. Find the zip and extract it
ZIP_FILE=$(find . -maxdepth 1 -name "*.zip" | head -n 1)
if [ -z "$ZIP_FILE" ]; then
    ZIP_FILE="MatrixOS.zip"
fi

if [ -f "$ZIP_FILE" ]; then
    echo "Extracting MatrixOS..."
    unzip -q "$ZIP_FILE"
    echo "Extraction complete!"
    
    # 5. Open the folder automatically
    xdg-open "$DEST_DIR"
else
    zenity --error --text="Download failed: Zip file not found."
    exit 1
fi
