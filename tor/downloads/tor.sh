#!/bin/bash
# Tor Browser Native Installer (Direct Installation Re-fix)
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Repoları quraşdır və YENİLƏ
echo "Preparing repositories..."
pkg install -y x11-repo tur-repo
pkg update -y

# 2. Birbaşa yükləməyə cəhd (Axtarış məntiqini ləğv etdik)
echo "Installing Tor and Tor Browser..."
if pkg install -y tor tor-browser; then
    echo "Official tor-browser installed successfully."
    ACTUAL_EXEC=$(command -v tor-browser || command -v torbrowser)
    FINAL_NAME="Tor Browser"
elif pkg install -y tor tor-browser-launcher; then
    echo "Installed via tor-browser-launcher."
    ACTUAL_EXEC=$(command -v tor-browser-launcher)
    FINAL_NAME="Tor Browser"
else
    echo "Official packages failed. Checking if Firefox is the only option..."
    pkg install -y tor firefox
    ACTUAL_EXEC=$(command -v firefox)
    FINAL_NAME="Tor (via Firefox)"
fi

# 3. İcra yoxlaması
if [ -z "$ACTUAL_EXEC" ]; then
    echo "ERROR: No browser could be installed."
    exit 1
fi

# 4. Shortcut yaradılması
echo "Creating desktop shortcut: $FINAL_NAME"
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
touch "$TMPDIR/.skip_shortcut"

# Köhnə bütün ikonları təmizlə
rm -f "$HOME/Desktop/Tor Browser.desktop"
rm -f "$HOME/Desktop/Tor (via Firefox).desktop"
rm -f "$HOME/Desktop/tor-browser.desktop"

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
echo "Installation Finished. Check your Desktop!"
exit 0
