# Troubleshooting

## Yocto

### Build fails with "No space left on device"
WSL vhdx too small. Expand to ~500 GB.

### Build extremely slow
Check that build tree is on ext4 (`/home/...`), not on `/mnt/c/`.

### Missing sstate hits after clean build
Verify `SSTATE_DIR` points to `_yocto-cache/sstate-cache` (relative to TOPDIR, not inside `build/`).

## Buildroot

*Will grow as issues are encountered.*

## WSL

### Scripts fail with "bad interpreter"
CRLF line endings. Run: `git config --global core.autocrlf false`
Re-clone or `dos2unix` affected files.

*This file grows organically. Every fix goes here.*
