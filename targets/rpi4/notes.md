# Raspberry Pi 4 — Target Notes

## Role
Primary sacrificial target: flash, boot, break, reflash.

## Hardware
- BCM2711 (4x Cortex-A72)
- 4 GB RAM
- microSD boot
- UART on GPIO 14/15 (pins 8/10)

## UART connection
```
RPi4 GPIO14 (TX) → USB-UART RX
RPi4 GPIO15 (RX) → USB-UART TX
RPi4 GND        → USB-UART GND
```

```bash
# On host
screen /dev/ttyUSB0 115200
# or
minicom -D /dev/ttyUSB0 -b 115200
```

## Boot media
- SD card (primary)
- U-Boot: installed in Phase 1 week 3

## Device Tree
- Stock DTB: `bcm2711-rpi-4-b.dtb`
- Overlays: `targets/rpi4/dt/overlays/`
