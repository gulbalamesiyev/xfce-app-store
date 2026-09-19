#!/bin/bash
# Tor Browser GUI Installer Wrapper (Stable & Shortcut Fix)
set -e

INSTALL_ROOT="${HOME}/.tor-browser"
CACHE_DIR="${HOME}/.cache/termux-pro-install"
mkdir -p "$CACHE_DIR" "$INSTALL_ROOT/logs" "$INSTALL_ROOT/bin"
LOG_FILE="${INSTALL_ROOT}/logs/install.log"

echo "🔧 Starting Tor Browser GUI Installation..." | tee -a "$LOG_FILE"

# 1. Install dependencies
pkg update -y
pkg install -y tor python python-gi python-gi-cairo gtk4 webkit2gtk-4.1 curl netcat-openbsd

# 2. Start Tor if not running
if ! nc -z 127.0.0.1 9050; then
    echo "📡 Starting Tor daemon..." | tee -a "$LOG_FILE"
    tor --quiet &
    sleep 7
fi

# 3. Execute Python Installer
# (Note: install.py should handle downloading and extracting real binaries)
if [ -f "$(dirname "$0")/install.py" ]; then
    python3 "$(dirname "$0")/install.py"
elif [ -f "$CACHE_DIR/install.py" ]; then
    python3 "$CACHE_DIR/install.py"
fi

# 4. Create the Launcher Script (Important!)
cat <<EOF > "$INSTALL_ROOT/bin/tor-browser-launcher"
#!/bin/bash
if ! nc -z 127.0.0.1 9050; then
    tor --quiet &
    sleep 3
fi
export http_proxy=socks5://127.0.0.1:9050
export https_proxy=socks5://127.0.0.1:9050
export ALL_PROXY=socks5://127.0.0.1:9050
python3 "$INSTALL_ROOT/main.py" "\$@"
EOF
chmod +x "$INSTALL_ROOT/bin/tor-browser-launcher"

# 5. Create Desktop Entry on the actual Desktop
echo "Creating desktop shortcut..." | tee -a "$LOG_FILE"
mkdir -p "$HOME/Desktop"

# Find icon (fallback to standard if not found)
ICON_PATH=$(find $PREFIX/share/icons -name "*tor-browser*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

cat <<EOF > "$HOME/Desktop/Tor Browser.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Tor Browser
Comment=Secure & Anonymous Browsing
Exec=$INSTALL_ROOT/bin/tor-browser-launcher
Icon=$ICON_PATH
Terminal=false
StartupNotify=true
Categories=Network;Security;WebBrowser;
EOF

chmod +x "$HOME/Desktop/Tor Browser.desktop"

# 6. Force XFCE to refresh the desktop
xfdesktop --reload 2>/dev/null || true

# 7. Signal success to the C app
touch "$CACHE_DIR/.skip_shortcut"

echo "🚀 Tor Browser GUI installation finished successfully." | tee -a "$LOG_FILE"
