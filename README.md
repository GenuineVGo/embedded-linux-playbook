# embedded-linux-playbook

Control plane for an embedded Linux skill-building journey: manifests, configs, scripts, drivers, and documentation.

## Objective

90-day structured ramp-up on embedded Linux (kernel, drivers, Yocto, Buildroot, Device Tree) by a senior embedded architect with 32 years of bare-metal and firmware experience (UEFI/EDK2, ARM Cortex-M, ARM Neoverse).

## Targets

| Target | Role | Status |
|--------|------|--------|
| Raspberry Pi 4 | Primary test target (flash, boot, break, reflash) | Active |
| QEMU aarch64 | Build validation without hardware | Active |
| Toradex Verdin iMX8M Plus | Industrial NXP target (decision at J45) | Planned |

## Quick start

```bash
# 1. Clone
git clone git@github.com:vincent/embedded-linux-playbook.git
cd embedded-linux-playbook

# 2. Bootstrap your host
make bootstrap-wsl      # MS-A2 (Yocto host)
make bootstrap-debian   # CM3588 (Buildroot host)

# 3. Build
make buildroot-rpi4     # on CM3588
make yocto-rpi4         # on MS-A2 (uses kas)
```

## Repository structure

```
embedded-linux-playbook/
├─ docs/          Documentation, troubleshooting, ADRs
├─ journal/       Daily logs and weekly summaries
├─ scripts/       Bootstrap, flash, log collection
├─ targets/       Per-board notes, DT overlays, U-Boot config
├─ buildroot/     BR2_EXTERNAL tree (custom packages, defconfigs)
├─ yocto/         kas manifests + meta-vincent layer
├─ kernel/        Out-of-tree modules, drivers, patches
├─ tools/         Docker fallback for Yocto builds
└─ Makefile       Unified entry point
```

## Milestones

| Tag | Phase | Criteria |
|-----|-------|----------|
| `J07` | Phase 0 | Two images (Buildroot + Yocto) boot on RPi4 |
| `J21` | Phase 1 | Custom kernel module, DT overlay, U-Boot interactive |
| `J49` | Phase 2 | Custom Yocto image with meta-vincent layer |
| `J77` | Phase 3 | I2C/SPI drivers integrated in both build systems |
| `J90` | Phase 4 | Integration project complete and documented |

## Build hosts

| Machine | Role |
|---------|------|
| MinisForum MS-A2 (R9 9955HX, 96 GB, WSL/Pengwin) | Yocto builds (kas) |
| FriendlyElec CM3588 Plus (RK3588, 32 GB, Debian) | Buildroot builds (native aarch64) |

## License

Apache-2.0 — see [LICENSE](LICENSE).
