#!/bin/bash

echo "=== MatrixOS Automated Installer ==="

# 1. Install dependencies (Python, pip, zenity, unzip)
if ! command -v zenity &> /dev/null || ! command -v pip3 &> /dev/null; then
    echo "Installing required system dependencies..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install zenity unzip python3 python3-pip -y
    elif command -v dnf &> /dev/null; then
        sudo dnf install zenity unzip python3 python3-pip -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -S zenity unzip python3 python-pip --noconfirm
    fi
fi

# Ensure mega.nz python downloader library is available
pip3 install --quiet mega.py

# 2. Open GUI folder picker for installation path
DEST_DIR=$(zenity --file-selection --directory --title="Select Where to Install MatrixOS")

if [ -z "$DEST_DIR" ]; then
    echo "Installation cancelled by user."
    exit 1
fi

echo "Installing to: $DEST_DIR"
cd "$DEST_DIR" || exit 1

# 3. Download MatrixOS using a robust Python-based MEGA downloader snippet
MEGA_URL="https://mega.nz/file/2LhBSRLQ#-DwZ8vn4P7O9Dj0rF5B9BN6C-6tXWEeD9Za7wtr3-Dk"

echo "Downloading MatrixOS (5.11 GB - this may take a few minutes)..."

python3 -c "
from mega import Mega
import sys

url = '$MEGA_URL'
try:
    m = Mega().data_from_url(url)
    mega = Mega()
    print('Connecting to MEGA...')
    mega.download_url(url, dest_path='.')
    print('Download finished successfully!')
except Exception as e:
    print(f'Error during download: {e}')
    sys.exit(1)
"

if [ $? -ne 0 ]; then
    zenity --error --text="Download failed. Check your internet connection or MEGA transfer limits."
    exit 1
fi

# 4. Find the downloaded zip and extract it
ZIP_FILE=$(find . -maxdepth 1 -name "*.zip" | head -n 1)

if [ -f "$ZIP_FILE" ]; then
    echo "Extracting $ZIP_FILE..."
    unzip -q "$ZIP_FILE"
    echo "Extraction complete!"
    
    # 5. Open the folder automatically
    xdg-open "$DEST_DIR"
else
    zenity --error --text="Download completed, but the zip file could not be located."
    exit 1
fi
