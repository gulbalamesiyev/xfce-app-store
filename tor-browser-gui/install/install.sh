#!/bin/bash
# Tor Browser GUI Installer Wrapper (FIXED)
set -e

INSTALL_ROOT="${HOME}/.tor-browser"
CACHE_DIR="${HOME}/.cache/tor-browser-install"
LOG_FILE="${INSTALL_ROOT}/logs/install.log"

mkdir -p "$CACHE_DIR" "$INSTALL_ROOT/logs"

echo "🔧 Starting Tor Browser GUI Installation..." | tee -a "$LOG_FILE"

# 1. Təməl asılılıqları yoxla və yüklə
pkg update -y
pkg install -y tor python python-pip curl netcat-openbsd

# 2. Tor Daemon-u yoxla/başlat
if ! nc -z 127.0.0.1 9050; then
    echo "📡 Starting Tor daemon..." | tee -a "$LOG_FILE"
    tor --quiet &
    sleep 7
fi

# 3. Python Installer-i işə sal
PYTHON_SCRIPT="$(dirname "$0")/install.py"
if [ -f "$PYTHON_SCRIPT" ]; then
    python3 "$PYTHON_SCRIPT"
else
    echo "❌ Error: install.py not found!" | tee -a "$LOG_FILE"
    exit 1
fi

# 4. Desktop Launcher yarat (Köhnə C kodunun gözlədiyi /tmp faylını Termux yoluna görə yarat)
[ -z "$TMPDIR" ] && TMPDIR=$PREFIX/tmp
touch "$TMPDIR/.skip_shortcut"

echo "🚀 Installation finished successfully."
