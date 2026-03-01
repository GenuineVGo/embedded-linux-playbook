#!/bin/bash
# fetch_sources.sh — Clone or update upstream sources
# Run this on your build host(s) to get the upstream repos
set -euo pipefail

SOURCES_DIR="${1:-$HOME/sources}"
TARGET="${2:-all}"
YOCTO_BRANCH="scarthgap"

usage() {
    cat <<EOF
Usage: $0 [sources_dir] [target]

  sources_dir : destination directory for cloned repos (default: \$HOME/sources)
  target      : one of 'all' (default), 'buildroot', 'yocto'

Examples:
  $0 ~/sources buildroot   # Buildroot + kernel only (CM3588+)
  $0 ~/sources yocto       # Poky (yocto) + kernel only (MS-A2)
  $0 ~/sources             # all
EOF
    exit 1
}

if [ "${SOURCES_DIR#-}" != "$SOURCES_DIR" ] || [ "$SOURCES_DIR" = "-h" ] || [ "$SOURCES_DIR" = "--help" ]; then
    usage
fi

case "$TARGET" in
    all)
        DO_BUILDROOT=1; DO_YOCTO=1; DO_KERNEL=1
        ;;
    buildroot)
        DO_BUILDROOT=1; DO_YOCTO=0; DO_KERNEL=1
        ;;
    yocto)
        DO_BUILDROOT=0; DO_YOCTO=1; DO_KERNEL=1
        ;;
    *)
        echo "Unknown target: $TARGET" >&2
        usage
        ;;
esac

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
if [ "${DO_BUILDROOT:-0}" -eq 1 ]; then
    clone_or_update buildroot https://gitlab.com/buildroot.org/buildroot.git
fi

# Yocto is handled by kas — this is for manual exploration only
if [ "${DO_YOCTO:-0}" -eq 1 ]; then
    clone_or_update poky git://git.yoctoproject.org/poky "$YOCTO_BRANCH"
fi

# Linux kernel (RPi4 fork, for manual compilation exercises)
if [ "${DO_KERNEL:-0}" -eq 1 ]; then
    clone_or_update linux-rpi https://github.com/raspberrypi/linux.git rpi-6.6.y
fi

echo ""
echo "Sources ready in: $SOURCES_DIR"
if [ "${DO_BUILDROOT:-0}" -eq 1 ]; then
    echo "  Buildroot: $SOURCES_DIR/buildroot"
fi
if [ "${DO_YOCTO:-0}" -eq 1 ]; then
    echo "  Poky:      $SOURCES_DIR/poky"
fi
if [ "${DO_KERNEL:-0}" -eq 1 ]; then
    echo "  Linux:     $SOURCES_DIR/linux-rpi"
fi
