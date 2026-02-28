### liblz4-tool not found on Debian Trixie / Pengwin
Debian Trixie renamed `liblz4-tool` to `lz4`.
Fix: replace `liblz4-tool` by `lz4` in `scripts/bootstrap_wsl.sh`.