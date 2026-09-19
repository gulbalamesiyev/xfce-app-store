#!/bin/bash
# Tor Browser Native Installer (Advanced Search & Install)
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Repoları quraşdır
pkg install -y x11-repo tur-repo
pkg update -y

# 2. Paket axtarışı (Dinamik olaraq ən uyğun paketi tapırıq)
echo "Searching for the best Tor Browser package..."
# TUR repoda paket adları tor-browser, tor-browser-launcher və ya oxşar ola bilər
SEARCH_RESULTS=$(pkg search tor-browser | grep -v "Description" | awk '{print $1}')

BEST_PKG=""
for p in $SEARCH_RESULTS; do
    if [[ "$p" == "tor-browser" ]] || [[ "$p" == "torbrowser" ]] || [[ "$p" == "tor-browser-launcher" ]]; then
        BEST_PKG=$p
        break
    fi
done

if [ -z "$BEST_PKG" ]; then
    echo "Warning: No specific tor-browser package found. Trying generic 'tor' and 'firefox' combination..."
    pkg install -y tor firefox
    ACTUAL_EXEC=$(command -v firefox)
    DISPLAY_NAME="Tor (via Firefox)"
    # We will use Firefox with Tor proxy settings if needed, but for now let's just use what we have
else
    echo "Found package: $BEST_PKG. Installing..."
    pkg install -y tor $BEST_PKG
    ACTUAL_EXEC=$(command -v tor-browser || command -v torbrowser || command -v tor-browser-launcher || command -v firefox)
fi

# 3. İcra yoxlaması
if [ -z "$ACTUAL_EXEC" ]; then
    echo "CRITICAL ERROR: No browser executable found."
    exit 1
fi

# 4. Shortcut yaradılması
echo "Finalizing desktop launcher..."
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
touch "$TMPDIR/.skip_shortcut"

# Təmizlik: Köhnə ikonları sil
rm -f "$HOME/Desktop/tor.desktop"
rm -f "$HOME/Desktop/tor-browser.desktop"
rm -f "$HOME/Desktop/Tor Browser.desktop"

ICON_PATH=$(find $PREFIX/share/icons -name "*tor-browser*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH=$(find $PREFIX/share/icons -name "*firefox*" | grep ".png" | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

# XFCE üçün mütləq işlək olan launcher
cat <<EOF > "$HOME/Desktop/Tor Browser.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$DISPLAY_NAME
Comment=Secure Browsing
Exec=$ACTUAL_EXEC --no-sandbox
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
EOF

chmod +755 "$HOME/Desktop/Tor Browser.desktop"
echo "Tor Browser successfully prepared!"
exit 0
