#!/bin/bash
# bootstrap_debian.sh — Install Buildroot dependencies on Debian/Ubuntu (CM3588)
set -euo pipefail

echo "=== Installing Buildroot dependencies ==="
sudo apt-get update
sudo apt-get install -y \
    build-essential gcc g++ make \
    libncurses5-dev libncursesw5-dev bc bison flex \
    libssl-dev python3 unzip rsync cpio wget git

echo "=== Git config (LF line endings) ==="
git config --global core.autocrlf false
git config --global core.eol lf

echo ""
echo "Done. Ready for: make buildroot-rpi4 BUILDROOT_SRC=/path/to/buildroot"
