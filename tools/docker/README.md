# Docker — Yocto Build Fallback

## When to use

When WSL gives you trouble:
- cgroups issues
- Network/git/sstate failures
- Filesystem weirdness

This is **not** the primary build path. It's the plan B.

## Build the image

```bash
docker build -t yocto-builder tools/docker/
```

## Run a build

```bash
docker run --rm \
    -v $(pwd):/work \
    -v $(pwd)/_yocto-cache:/work/_yocto-cache \
    yocto-builder \
    kas build yocto/kas/rpi4.yml
```

The container runs as user `builder` (not root) to avoid file ownership issues on mounted volumes. Cache paths align with the kas manifest (`_yocto-cache/` relative to workdir).
