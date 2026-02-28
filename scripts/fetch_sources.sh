#!/bin/bash
# fetch_sources.sh — Clone or update upstream sources
# Run this on your build host(s) to get the upstream repos
set -euo pipefail

SOURCES_DIR="${1:-$HOME/sources}"
YOCTO_BRANCH="scarthgap"

mkdir -p "$SOURCES_DIR"
cd "$SOURCES_DIR"

clone_or_update() {
    local name="$1" url="$2" branch="${3:-}"
    if [ -d "$name" ]; then
        echo "=== Updating $name ==="
        cd "$name"
        git fetch --all
        if [ -n "$branch" ]; then git checkout "$branch" && git pull; fi
        cd ..
    else
        echo "=== Cloning $name ==="
        if [ -n "$branch" ]; then
            git clone -b "$branch" "$url" "$name"
        else
            git clone "$url" "$name"
        fi
    fi
}

echo "=== Fetching sources to $SOURCES_DIR ==="

# Buildroot (latest stable)
clone_or_update buildroot https://gitlab.com/buildroot.org/buildroot.git

# Yocto is handled by kas — this is for manual exploration only
clone_or_update poky git://git.yoctoproject.org/poky "$YOCTO_BRANCH"

# Linux kernel (RPi4 fork, for manual compilation exercises)
clone_or_update linux-rpi https://github.com/raspberrypi/linux.git rpi-6.6.y

echo ""
echo "Sources ready in: $SOURCES_DIR"
echo "  Buildroot: $SOURCES_DIR/buildroot"
echo "  Poky:      $SOURCES_DIR/poky"
echo "  Linux:     $SOURCES_DIR/linux-rpi"
