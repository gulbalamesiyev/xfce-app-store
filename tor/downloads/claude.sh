#!/bin/bash
# Claude CLI Native Installer for Termux-Pro
echo "Installing Claude CLI (Anthropic)..."

# 1. Install dependencies
pkg update -y
pkg install -y nodejs-lts binutils

# 2. Install via NPM with --unsafe-perm to allow post-install scripts
echo "Running NPM installation..."
npm install -g @anthropic-ai/claude-code --unsafe-perm

# 3. Manual fix for the postinstall issue seen in the screenshot
GLOBAL_PREFIX=$(npm config get prefix)
INSTALL_JS="$GLOBAL_PREFIX/lib/node_modules/@anthropic-ai/claude-code/install.cjs"

if [ -f "$INSTALL_JS" ]; then
    echo "Executing manual post-install fix..."
    node "$INSTALL_JS"
else
    echo "Post-install script not found at $INSTALL_JS, checking alternative paths..."
    # Fallback search for Termux specific global paths
    ALT_PATH="$PREFIX/lib/node_modules/@anthropic-ai/claude-code/install.cjs"
    if [ -f "$ALT_PATH" ]; then
        node "$ALT_PATH"
    fi
fi

# 4. Refresh UI trigger for App Store
mkdir -p "$HOME/.cache/termux-pro-install"
touch "$HOME/.cache/termux-pro-install/.refresh_ui"

echo "Claude CLI successfully installed and configured!"
exit 0
