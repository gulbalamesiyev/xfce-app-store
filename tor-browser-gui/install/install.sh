#!/bin/bash
# Tor Browser GUI Installer for Termux-Pro X11
# Based on the production-ready architecture

set -e

INSTALL_DIR="$HOME/.tor-browser"
LOG_FILE="$INSTALL_DIR/logs/install.log"
mkdir -p "$INSTALL_DIR/logs" "$INSTALL_DIR/bin" "$INSTALL_DIR/data"

echo "[$(date)] Starting installation..." | tee -a "$LOG_FILE"

# 1. Install System Dependencies
echo "Installing dependencies..." | tee -a "$LOG_FILE"
pkg update -y
pkg install -y tor gtk4 webkit2gtk-4.1 python python-gi python-gi-cairo curl coreutils

# 2. Check Tor Daemon
echo "Checking Tor daemon..." | tee -a "$LOG_FILE"
if ! nc -z 127.0.0.1 9050; then
    echo "Starting Tor..." | tee -a "$LOG_FILE"
    tor --quiet &
    sleep 5
fi

# 3. Download App Files (Simulated for MVP, assuming files are in repo)
# In production, we'd download the tarball from GitHub
echo "Setting up application files..." | tee -a "$LOG_FILE"
cp -r ../* "$INSTALL_DIR/" 2>/dev/null || true

# 4. Create Launcher Script
cat <<EOF > "$INSTALL_DIR/bin/tor-browser-launcher"
#!/bin/bash
if ! nc -z 127.0.0.1 9050; then
    tor --quiet &
    sleep 3
fi
export http_proxy=socks5://127.0.0.1:9050
export https_proxy=socks5://127.0.0.1:9050
export ALL_PROXY=socks5://127.0.0.1:9050
python3 "$INSTALL_DIR/main.py" "\$@"
EOF
chmod +x "$INSTALL_DIR/bin/tor-browser-launcher"

# 5. Create Desktop Entry
mkdir -p "$HOME/.local/share/applications"
cat <<EOF > "$HOME/.local/share/applications/org.torproject.torbrowser.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Tor Browser
Comment=Anonymous web browsing via Tor Network
Exec=$INSTALL_DIR/bin/tor-browser-launcher %u
Icon=tor-browser
Terminal=false
StartupNotify=true
Categories=Network;Security;WebBrowser;
EOF

# Copy desktop file to Desktop for easy access
cp "$HOME/.local/share/applications/org.torproject.torbrowser.desktop" "$HOME/Desktop/"
chmod +x "$HOME/Desktop/org.torproject.torbrowser.desktop"

# 6. Finalize
echo "Done. Tor Browser GUI installed." | tee -a "$LOG_FILE"
touch /tmp/.skip_shortcut
exit 0
