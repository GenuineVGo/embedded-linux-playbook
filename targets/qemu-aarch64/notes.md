# QEMU aarch64 — Target Notes

## Role
Build validation target. No hardware needed.

## Usage (Buildroot)
```bash
# After: make qemu_aarch64_virt_defconfig && make -j$(nproc)
qemu-system-aarch64 \
    -M virt \
    -cpu cortex-a53 \
    -nographic \
    -kernel output/images/Image \
    -append "console=ttyAMA0" \
    -drive file=output/images/rootfs.ext2,format=raw
```

## When to use
- Phase 0: validate Buildroot toolchain before flashing RPi4
- Anytime: quick smoke test without SD card cycle
