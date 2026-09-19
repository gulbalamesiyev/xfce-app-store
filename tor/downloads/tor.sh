#!/bin/bash
# Tor Browser Native Installer for Termux-Pro X11 (Optimized)
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Reponu və paketləri quraşdır
pkg update -y
pkg install -y tor
# Tor Browser üçün TUR (Termux User Repository) lazımdır
pkg install -y tur-repo
pkg install -y tor-browser

# 2. İkon və İcra faylını yoxla
# Bəzi sistemlərdə komanda 'tor-browser' yerinə 'tor-browser-launcher' ola bilər
ACTUAL_EXEC=$(command -v tor-browser || command -v tor-browser-launcher)

if [ -z "$ACTUAL_EXEC" ]; then
    echo "ERROR: tor-browser not found after installation!"
    exit 1
fi

# 3. İkonu tap
ICON_PATH=$(find $PREFIX/share/icons -name "*tor-browser*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

# 4. Masaüstü fayllarını təmizlə və yenisini yarat
rm -f "$HOME/Desktop/tor.desktop"
rm -f "$HOME/Desktop/tor-browser.desktop"

cat <<EOF > "$HOME/Desktop/Tor Browser.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Tor Browser
Comment=Anonymizing Web Browser
Exec=$ACTUAL_EXEC
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
EOF

chmod +755 "$HOME/Desktop/Tor Browser.desktop"

# 5. App Store-a de ki, shortcut-ı mən yaratdım
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
touch "$TMPDIR/.skip_shortcut"

echo "Tor Browser successfully installed!"
exit 0
