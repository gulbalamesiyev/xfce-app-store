#!/bin/bash
# Optimized Bridge for Tor Browser GUI (V2)
# Avoids /tmp due to Termux permission restrictions

INSTALLER_DIR="$(pwd)/tor-browser-gui/install"
CACHE_DIR="$HOME/.cache/termux-pro-install"
mkdir -p "$CACHE_DIR"

if [ -f "$INSTALLER_DIR/install.sh" ]; then
    echo "Running local installer..."
    bash "$INSTALLER_DIR/install.sh"
else
    echo "Downloading remote installer components..."
    BASE_URL="https://raw.githubusercontent.com/gulbalamesiyev/xfce-app-store/main/tor-browser-gui/install"

    curl -L "$BASE_URL/install.sh" -o "$CACHE_DIR/install.sh"
    curl -L "$BASE_URL/install.py" -o "$CACHE_DIR/install.py"

    if [ -f "$CACHE_DIR/install.sh" ]; then
        bash "$CACHE_DIR/install.sh"
    else
        echo "❌ Critical Error: Failed to download installer components."
        exit 1
    fi
fi
