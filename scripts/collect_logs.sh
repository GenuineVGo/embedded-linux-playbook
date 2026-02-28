#!/bin/bash
# collect_logs.sh — Collect debug info from RPi4 via SSH
# Usage: collect_logs.sh [user@host]
set -euo pipefail

RPI_HOST="${1:-${RPI_HOST:-root@rpi4.local}}"
LOGDIR="logs/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$LOGDIR"

echo "=== Collecting logs from $RPI_HOST ==="

run_remote() {
    ssh -o ConnectTimeout=5 "$RPI_HOST" "$@" 2>/dev/null || echo "(command failed)"
}

echo "=== System info ==="
run_remote "uname -a" > "$LOGDIR/uname.txt"
run_remote "cat /proc/version" > "$LOGDIR/kernel-version.txt"
run_remote "cat /proc/cmdline" > "$LOGDIR/cmdline.txt"

echo "=== dmesg ==="
run_remote "dmesg" > "$LOGDIR/dmesg.txt"
run_remote "dmesg | grep -iE 'error|fail|warn'" > "$LOGDIR/dmesg-errors.txt"

echo "=== /proc info ==="
run_remote "cat /proc/interrupts" > "$LOGDIR/interrupts.txt"
run_remote "cat /proc/iomem" > "$LOGDIR/iomem.txt"
run_remote "cat /proc/devices" > "$LOGDIR/devices.txt"
run_remote "cat /proc/cpuinfo" > "$LOGDIR/cpuinfo.txt"
run_remote "cat /proc/meminfo" > "$LOGDIR/meminfo.txt"

echo "=== Device tree ==="
run_remote "ls /sys/firmware/devicetree/base/" > "$LOGDIR/dt-root.txt"
run_remote "ls /sys/bus/i2c/devices/" > "$LOGDIR/i2c-devices.txt"
run_remote "ls /sys/bus/spi/devices/" > "$LOGDIR/spi-devices.txt"

echo "=== Modules ==="
run_remote "lsmod" > "$LOGDIR/lsmod.txt"

echo ""
echo "Logs saved to: $LOGDIR"
echo "NOTE: These logs are gitignored. Copy specific files to journal/ if needed."
