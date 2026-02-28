# Environment Setup

## Git configuration (do this FIRST)

Before any commit, lock line endings to LF. CRLF under WSL is a silent build-breaker.

```bash
git config --global core.autocrlf false
git config --global core.eol lf
```

The repo includes a `.gitattributes` that enforces LF for all text files.

## MS-A2 (Yocto host — WSL/Pengwin)

```bash
make bootstrap-wsl
```

### WSL checklist

- [ ] `/etc/wsl.conf` has `systemd=true`
- [ ] Build tree on ext4 (`/home/...`), **never** `/mnt/c/`
- [ ] WSL vhdx has ~500 GB allocated
- [ ] Yocto caches: `_yocto-cache/` created relative to kas workdir (or symlinked to large disk)

## CM3588 Plus (Buildroot host — Debian)

```bash
make bootstrap-debian
```

## Raspberry Pi 4 (target)

- UART cable connected (debug ritual starts J1)
- SD card reader available
- `make flash-rpi4 FLASH_DEV=/dev/sdX`
