#!/bin/bash
# flash_rpi4.sh — Flash an image to SD card for Raspberry Pi 4
# Usage: flash_rpi4.sh /dev/sdX path/to/image.img
set -euo pipefail

DEVICE="${1:?Usage: flash_rpi4.sh /dev/sdX path/to/image.img}"
IMAGE="${2:-}"

if [ ! -b "$DEVICE" ]; then
    echo "ERROR: $DEVICE is not a block device"
    exit 1
fi

# If no image specified, find the most recent one
if [ -z "$IMAGE" ]; then
    IMAGE=$(find . -maxdepth 4 \( -name '*.img' -o -name '*.wic' \) -printf '%T@ %p\n' 2>/dev/null \
            | sort -rn | head -1 | cut -d' ' -f2-)
    if [ -z "$IMAGE" ]; then
        echo "ERROR: No .img or .wic file found. Build first, or specify path."
        echo "Usage: flash_rpi4.sh /dev/sdX path/to/image.img"
        exit 1
    fi
    echo "Auto-selected most recent image: $IMAGE"
    read -rp "Use this image? [y/N] " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "Aborted. Specify image explicitly:"
        echo "  flash_rpi4.sh $DEVICE path/to/image.img"
        exit 1
    fi
fi

if [ ! -f "$IMAGE" ]; then
    echo "ERROR: Image not found: $IMAGE"
    exit 1
fi

# Safety check
echo ""
echo "WARNING: This will erase ALL data on $DEVICE"
echo "Device:"
lsblk "$DEVICE" 2>/dev/null || true
echo "Image: $IMAGE ($(du -h "$IMAGE" | cut -f1))"
echo ""
read -rp "Type 'YES' to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

echo "Flashing: $IMAGE -> $DEVICE"
sudo dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync
sync
echo "Done. Remove SD card and boot the RPi4."
