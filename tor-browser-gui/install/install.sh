#!/bin/bash
# Tor Browser GUI Installer Wrapper (Stable)
set -e

INSTALL_ROOT="${HOME}/.tor-browser"
CACHE_DIR="${HOME}/.cache/termux-pro-install"

mkdir -p "$CACHE_DIR" "$INSTALL_ROOT/logs"
LOG_FILE="${INSTALL_ROOT}/logs/install.log"

echo "🔧 Starting Tor Browser GUI Installation..." | tee -a "$LOG_FILE"

# 1. Install dependencies
pkg update -y
pkg install -y tor python python-pip curl netcat-openbsd

# 2. Start Tor if not running
if ! nc -z 127.0.0.1 9050; then
    echo "📡 Starting Tor daemon..." | tee -a "$LOG_FILE"
    tor --quiet &
    sleep 7
fi

# 3. Execute Python Installer
# Look for install.py in the same directory as this script, or in the cache
if [ -f "$(dirname "$0")/install.py" ]; then
    python3 "$(dirname "$0")/install.py"
elif [ -f "$CACHE_DIR/install.py" ]; then
    python3 "$CACHE_DIR/install.py"
else
    echo "❌ Error: install.py not found!" | tee -a "$LOG_FILE"
    exit 1
fi

# 4. Signal success to the C app
touch "$CACHE_DIR/.skip_shortcut"

echo "🚀 Tor Browser GUI installation script finished."
