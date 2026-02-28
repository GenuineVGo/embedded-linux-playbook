# Yocto / OpenEmbedded

## kas workflow

```bash
# Build
kas build yocto/kas/rpi4.yml

# Interactive shell
kas shell yocto/kas/rpi4.yml
```

## Cache strategy

Caches are stored in `_yocto-cache/` relative to kas TOPDIR (defined in `kas/common.yml`). Symlink to a large disk if needed:

```bash
ln -s /mnt/bigdisk/yocto-cache /path/to/kas-workdir/_yocto-cache
```

- `DL_DIR`: source archives (~5–15 GB), shared across builds
- `SSTATE_DIR`: compiled results (~30–80 GB), turns 2h rebuild into 5 min

## Build dir: NVMe, not tmpfs

Unlike Buildroot (3–8 GB, tmpfs-friendly), Yocto's `tmp/` reaches 15–40+ GB for a minimal image. Tmpfs will fill up mid-build and crash. Keep the build on NVMe ext4 (WSL native filesystem).

To reduce disk usage at the cost of slower incremental rebuilds:

```bash
# In local.conf or kas local_conf_header
INHERIT += "rm_work"
```

`rm_work` cleans each recipe's workdir after it's built. Saves 10–30 GB but means you can't inspect intermediate build artifacts.

*Content will grow with Phase 2.*
