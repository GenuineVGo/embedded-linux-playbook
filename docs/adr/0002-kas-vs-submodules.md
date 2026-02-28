# ADR 0002 — kas vs Git Submodules for Yocto Source Management

## Status
Accepted

## Context
Yocto builds require multiple upstream layers (poky, meta-openembedded, meta-raspberrypi, etc.). These must be pinned to specific revisions for reproducibility.

Two standard approaches exist:
- **Git submodules**: pin repos as submodules in the main repo
- **kas**: YAML manifest describing repos, revisions, and layer configuration

## Decision
Use **kas** manifests (stored in `yocto/kas/`).

## Rationale
- kas is the industry standard for Yocto environment management
- Submodules are fragile: forgotten `--recurse-submodules`, detached HEAD issues, painful updates
- kas manifests are human-readable YAML, easy to diff and review
- kas integrates `local.conf` headers directly in the manifest
- kas supports multiple machine configs (rpi4.yml, verdin-imx8mp.yml) sharing a common base

## Consequences
- Upstream Yocto sources are never stored in the repo
- `kas build yocto/kas/rpi4.yml` is the canonical build command
- Adding a new target = adding a new `.yml` file
