#!/bin/bash
# Tor Browser Native Installer for Termux-Pro X11 (Ultra-Robust)
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Repoları aktivləşdir
echo "Enabling repositories..."
pkg install -y x11-repo tur-repo

# 2. BÜTÜN repoları yenilə (TUR repodakı paketləri görmək üçün bu mütləqdir)
echo "Updating package lists..."
pkg update -y

# 3. Paketləri yüklə
echo "Installing Tor and Tor Browser..."
pkg install -y tor tor-browser

# 4. İcra faylını tap
ACTUAL_EXEC=$(command -v tor-browser || command -v tor-browser-launcher || command -v tor)

if ! command -v tor-browser >/dev/null 2>&1; then
    echo "WARNING: tor-browser not found in path, trying fallback..."
fi

# 5. İkonu tap
ICON_PATH=$(find $PREFIX/share/icons -name "*tor-browser*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

# 6. Masaüstü faylını yarat
echo "Creating desktop launcher..."
rm -f "$HOME/Desktop/Tor Browser.desktop"

cat <<EOF > "$HOME/Desktop/Tor Browser.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Tor Browser
Comment=Secure Browsing
Exec=tor-browser
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
EOF

chmod +755 "$HOME/Desktop/Tor Browser.desktop"

# 7. App Store-a məlumat ver
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
touch "$TMPDIR/.skip_shortcut"

echo "Installation complete!"
exit 0
