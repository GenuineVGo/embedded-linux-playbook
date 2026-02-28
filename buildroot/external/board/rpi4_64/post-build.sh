#!/bin/bash
# post-build.sh — Buildroot post-build hook for RPi4
# Runs after rootfs is built, before image is created
# $TARGET_DIR contains the root filesystem
set -euo pipefail

echo "=== Post-build: RPi4 customizations ==="

# Example: set hostname
echo "embedded-playbook" > "${TARGET_DIR}/etc/hostname"
