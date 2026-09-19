#!/bin/bash
# Bridge script to the new Tor Browser GUI Installer
# Part of the Termux Pro X11 Stage V8 Optimization

REPO_DIR=$(pwd)
INSTALLER_SCRIPT="$REPO_DIR/tor-browser-gui/install/install.sh"

if [ -f "$INSTALLER_SCRIPT" ]; then
    echo "Transitioning to Tor Browser GUI Installer..."
    bash "$INSTALLER_SCRIPT"
else
    echo "New installer not found locally. Falling back to remote execution..."
    # Fallback to remote if local fails (e.g. if running directly from App Store without full clone)
    URL="https://raw.githubusercontent.com/gulbalamesiyev/xfce-app-store/main/tor-browser-gui/install/install.sh"
    curl -L "$URL" -o /tmp/tor_install.sh && bash /tmp/tor_install.sh
fi
