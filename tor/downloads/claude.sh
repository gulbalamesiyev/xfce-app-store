#!/bin/bash
# Claude CLI Native Installer for Termux-Pro (V2 - Fix for post-install scripts)
echo "Installing Claude CLI (Anthropic)..."

# 1. Install system dependencies
pkg update -y
pkg install -y nodejs-lts binutils curl

# 2. Configure NPM to allow scripts for this package globally (to be sure)
echo "Configuring NPM permissions..."
npm config set allow-scripts=@anthropic-ai/claude-code --location=user || true

# 3. Install via NPM with explicit script allowance
echo "Running NPM installation with script allowance..."
npm install -g @anthropic-ai/claude-code --allow-scripts=@anthropic-ai/claude-code --unsafe-perm

# 4. Verification and Manual Trigger if needed
GLOBAL_PREFIX=$(npm config get prefix)
INSTALL_JS="$GLOBAL_PREFIX/lib/node_modules/@anthropic-ai/claude-code/install.cjs"

if [ -f "$INSTALL_JS" ]; then
    echo "Verifying installation components..."
    # If the app still complains, we run it manually
    node "$INSTALL_JS" || echo "Post-install script execution notice: check if platform-native dependencies are ready."
fi

# 5. Refresh UI trigger for App Store
mkdir -p "$HOME/.cache/termux-pro-install"
touch "$HOME/.cache/termux-pro-install/.refresh_ui"

echo "Claude CLI installation process finished!"
exit 0
