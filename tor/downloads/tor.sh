#!/bin/bash
# Tor Browser Native Installer (Advanced Search Fix)
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Repoları quraşdır və tam yenilə
pkg install -y x11-repo tur-repo
pkg update -y

# 2. Dəqiq paket axtarışı
echo "Searching for tor-browser in repositories..."
# Termux-da paket adı 'tor-browser/tur' formatında ola bilər, onu təmizləyirik
BEST_PKG=$(pkg search tor-browser | grep "^tor-browser" | awk '{print $1}' | cut -d/ -f1 | head -n 1)

if [ -z "$BEST_PKG" ]; then
    echo "Tor Browser package not found. Checking for alternative: tor-browser-launcher"
    BEST_PKG=$(pkg search tor-browser-launcher | grep "^tor-browser-launcher" | awk '{print $1}' | cut -d/ -f1 | head -n 1)
fi

if [ -n "$BEST_PKG" ]; then
    echo "Found official package: $BEST_PKG. Installing..."
    pkg install -y tor "$BEST_PKG"
    ACTUAL_EXEC=$(command -v tor-browser || command -v torbrowser || command -v tor-browser-launcher)
    FINAL_NAME="Tor Browser"
else
    echo "No Tor Browser package found. Falling back to Firefox with Tor proxy..."
    pkg install -y tor firefox
    ACTUAL_EXEC=$(command -v firefox)
    FINAL_NAME="Tor (via Firefox)"
fi

# 3. İcra yoxlaması
if [ -z "$ACTUAL_EXEC" ]; then
    echo "ERROR: No browser found!"
    exit 1
fi

# 4. Shortcut yaradılması
echo "Creating desktop shortcut: $FINAL_NAME"
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
touch "$TMPDIR/.skip_shortcut"

rm -f "$HOME/Desktop/Tor Browser.desktop"
rm -f "$HOME/Desktop/Tor (via Firefox).desktop"

ICON_PATH=$(find $PREFIX/share/icons -name "*tor-browser*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH=$(find $PREFIX/share/icons -name "*firefox*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

cat <<EOF > "$HOME/Desktop/$FINAL_NAME.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$FINAL_NAME
Comment=Secure Browsing
Exec=$ACTUAL_EXEC --no-sandbox
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
EOF

chmod +755 "$HOME/Desktop/$FINAL_NAME.desktop"
echo "Done! Launcher created on Desktop."
exit 0
