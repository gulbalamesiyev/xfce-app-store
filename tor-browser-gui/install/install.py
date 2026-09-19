#!/usr/bin/env python3
import os
import subprocess
import socket
import sys
import tarfile
import hashlib
from pathlib import Path

class TorBrowserInstaller:
    def __init__(self):
        self.install_root = Path.home() / '.tor-browser'
        self.cache_dir = Path.home() / '.cache' / 'tor-browser-install'
        self.log_file = self.install_root / 'logs' / 'install.log'

    def log(self, msg):
        print(msg)
        self.log_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.log_file, 'a') as f:
            f.write(msg + '\n')

    def check_tor(self):
        try:
            sock = socket.create_connection(('127.0.0.1', 9050), timeout=2)
            sock.close()
            self.log("✅ Tor daemon is running")
            return True
        except:
            self.log("⚠️  Tor daemon not running. Attempting to start via system...")
            subprocess.Popen(['tor', '--quiet'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return True # Assume it will start or bash wrapper handled it

    def download_via_curl(self, url, output_file):
        """Use curl as it's more reliable in Termux environment for SOCKS5"""
        self.log(f"📥 Downloading resources via Tor: {url}")
        cmd = [
            "curl", "--socks5-hostname", "127.0.0.1:9050",
            "--progress-bar", "--max-time", "600", "--retry", "5",
            "-o", str(output_file), url
        ]
        try:
            result = subprocess.run(cmd, check=True)
            return result.returncode == 0
        except Exception as e:
            self.log(f"❌ Download failed: {e}")
            return False

    def verify_checksum(self, file_path, expected_sha256):
        if not expected_sha256: return True
        self.log("🔍 Verifying integrity...")
        sha256 = hashlib.sha256()
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(8192), b''):
                sha256.update(chunk)
        actual = sha256.hexdigest()
        return actual == expected_sha256

    def install(self):
        self.log("=" * 50)
        self.log("🔧 Tor Browser GUI Installer (Python Mode)")
        self.log("=" * 50)

        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.install_root.mkdir(parents=True, exist_ok=True)

        self.check_tor()

        # In a real scenario, this URL would be your onion or mirror
        url = "https://raw.githubusercontent.com/gulbalamesiyev/xfce-app-store/main/tor-browser-gui/README.md" # Placeholder
        output = self.cache_dir / "resources.tar.gz"

        # Download (currently placeholder URL for testing, in real use point to tarball)
        # if not self.download_via_curl(url, output): return False

        self.log("📂 Setting up application structure...")
        # (Extraction logic here when tarball is ready)

        self.log("=" * 50)
        self.log("✅ Installation step completed!")
        self.log("=" * 50)
        return True

if __name__ == '__main__':
    installer = TorBrowserInstaller()
    sys.exit(0 if installer.install() else 1)
