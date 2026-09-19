#!/bin/bash
# Tor Browser Native Installer (Final Fix)
PKG_NAME=$1
DISPLAY_NAME=$2
EXEC_NAME=$3

echo "Custom Installing $DISPLAY_NAME..."

# 1. Repoları təmiz və dəqiq şəkildə qoş
echo "Adding repositories..."
pkg install -y x11-repo || true
pkg install -y tur-repo || true

# 2. Tam sistem yeniləməsi (Paketlərin görünməsi üçün mütləqdir)
echo "Syncing with cloud repositories..."
apt update && apt upgrade -y

# 3. Yükləməyə cəhd et
echo "Attempting to install tor-browser..."
if pkg install -y tor tor-browser; then
    echo "Installation successful!"
else
    echo "Standard installation failed. Searching for alternative packages..."
    # Bəzən paket adı fərqli ola bilər və ya başqa asılılıq istəyər
    pkg install -y tor
    if pkg install -y tor-browser-launcher; then
        echo "Installed via launcher!"
    else
        echo "CRITICAL ERROR: tor-browser package not found in any repository."
        echo "Please run 'pkg search tor-browser' manually to check availability."
        exit 1
    fi
fi

# 4. İcra faylını və ikonu yalnız yükləmə uğurludursa tap
ACTUAL_EXEC=$(command -v tor-browser || command -v tor-browser-launcher)

if [ -n "$ACTUAL_EXEC" ]; then
    echo "Creating desktop launcher..."
    ICON_PATH=$(find $PREFIX/share/icons -name "*tor-browser*" | grep ".png" | head -n 1)
    [ -z "$ICON_PATH" ] && ICON_PATH="tor-browser"

    rm -f "$HOME/Desktop/Tor Browser.desktop"
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

    # App Store-a shortcut yaratmağı dayandır de
    [ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
    touch "$TMPDIR/.skip_shortcut"
    echo "Success!"
else
    echo "Installation failed, skipping shortcut creation."
    exit 1
fi
