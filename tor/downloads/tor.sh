#!/bin/bash
# Optimized Bridge for Tor Browser GUI
REPO_DIR=$(pwd)
INSTALLER_DIR="$REPO_DIR/tor-browser-gui/install"
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp

if [ -f "$INSTALLER_DIR/install.sh" ]; then
    echo "Running local installer..."
    bash "$INSTALLER_DIR/install.sh"
else
    echo "Downloading remote installer to $HOME/.cache..."
    mkdir -p "$HOME/.cache"
    REMOTE_URL="https://raw.githubusercontent.com/gulbalamesiyev/xfce-app-store/main/tor-browser-gui/install/install.sh"
    PYTHON_REMOTE="https://raw.githubusercontent.com/gulbalamesiyev/xfce-app-store/main/tor-browser-gui/install/install.py"

    curl -L "$REMOTE_URL" -o "$HOME/.cache/install.sh"
    curl -L "$PYTHON_REMOTE" -o "$HOME/.cache/install.py"
    bash "$HOME/.cache/install.sh"
fi
