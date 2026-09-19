#!/bin/bash
# Tor Browser Native Installer for Termux-Pro X11
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Paketləri yüklə
pkg install -y tor tor-browser

# 2. Brauzerin öz ikonunu tap və mütləq yolu təyin et
ICON_PATH=$(find $PREFIX/share/icons -name "tor-browser.png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

# 3. Masaüstü faylını yarat
cat <<EOF > "$HOME/Desktop/tor-browser.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Tor Browser
Comment=Anonymizing Web Browser
Exec=tor-browser
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
EOF

chmod +755 "$HOME/Desktop/tor-browser.desktop"

# 4. App Store-a de ki, shortcut-ı mən yaratdım, sən qarışma
touch /tmp/.skip_shortcut

echo "Tor Browser successfully installed with native launcher!"
exit 0
