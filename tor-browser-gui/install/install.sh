#!/bin/bash
# Tor Browser GUI Installer Wrapper (Dependency Fix)
set -e

INSTALL_ROOT="${HOME}/.tor-browser"
CACHE_DIR="${HOME}/.cache/termux-pro-install"
mkdir -p "$CACHE_DIR" "$INSTALL_ROOT/logs" "$INSTALL_ROOT/bin"
LOG_FILE="${INSTALL_ROOT}/logs/install.log"

echo "🔧 Starting Tor Browser GUI Installation..." | tee -a "$LOG_FILE"

# 1. Update and enable repos
echo "Updating repositories..." | tee -a "$LOG_FILE"
pkg update -y
pkg install -y x11-repo tur-repo

# 2. Install dependencies with correct Termux names
# 'pygobject' is the standard name for Python GTK bindings in Termux/X11
echo "Installing system dependencies..." | tee -a "$LOG_FILE"
pkg install -y tor python pygobject gtk4 webkit2gtk-4.1 curl netcat-openbsd

# 3. Start Tor if not running
if ! nc -z 127.0.0.1 9050; then
    echo "📡 Starting Tor daemon..." | tee -a "$LOG_FILE"
    tor --quiet &
    sleep 7
fi

# 4. Execute Python Installer
if [ -f "$(dirname "$0")/install.py" ]; then
    python3 "$(dirname "$0")/install.py"
elif [ -f "$CACHE_DIR/install.py" ]; then
    python3 "$CACHE_DIR/install.py"
fi

# 5. Create the Launcher Script
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

# 6. Create Desktop Entry
echo "Creating desktop shortcut..." | tee -a "$LOG_FILE"
mkdir -p "$HOME/Desktop"
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
xfdesktop --reload 2>/dev/null || true
touch "$CACHE_DIR/.skip_shortcut"

echo "🚀 Tor Browser GUI installation finished successfully." | tee -a "$LOG_FILE"
