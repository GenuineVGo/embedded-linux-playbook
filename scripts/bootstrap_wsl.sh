#!/bin/bash
# bootstrap_wsl.sh — Install Yocto (Scarthgap) dependencies on WSL/Pengwin
set -euo pipefail

echo "=== Installing Yocto build dependencies ==="
sudo apt-get update
sudo apt-get install -y \
    gawk wget git diffstat unzip texinfo gcc \
    build-essential chrpath socat cpio python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 python3-subunit zstd \
    liblz4-tool file locales libacl1

echo "=== Installing kas ==="
pip install kas --break-system-packages

echo "=== Setting up locale ==="
sudo sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen
sudo locale-gen

echo "=== Yocto caches ==="
echo "Caches will be created relative to TOPDIR by kas (../_yocto-cache/)."
echo "If you need them on a separate disk, create a symlink:"
echo "  ln -s /mnt/bigdisk/yocto-cache /path/to/kas-workdir/_yocto-cache"

echo "=== Git config (LF line endings) ==="
git config --global core.autocrlf false
git config --global core.eol lf

echo ""
echo "=== WSL checklist ==="
echo "Verify the following in /etc/wsl.conf:"
echo "  [boot]"
echo "  systemd=true"
echo ""
echo "Verify WSL vhdx has ~500 GB allocated."
echo "Verify build tree is on ext4 (/home/...) NOT /mnt/c/."
echo ""
echo "Done. Ready for: make yocto-rpi4"
