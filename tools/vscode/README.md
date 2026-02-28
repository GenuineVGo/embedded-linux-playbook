# VSCode Configuration

## Setup

Copy these files to `.vscode/` at the repo root:

```bash
mkdir -p .vscode
cp tools/vscode/settings.json .vscode/
cp tools/vscode/c_cpp_properties.json .vscode/
cp tools/vscode/extensions.json .vscode/
cp tools/vscode/tasks.json .vscode/
```

VSCode will prompt to install recommended extensions on first open.

## Kernel IntelliSense

The `c_cpp_properties.json` file needs kernel headers to work. Without them, IntelliSense underlines everything in red and Go to Definition (`F12`) doesn't work.

### On CM3588 (native, via Remote-SSH)

```bash
# Option A: install headers for the running kernel
sudo apt install linux-headers-$(uname -r)

# Option B: use the RPi kernel source tree
cd ~/sources/linux-rpi
make ARCH=arm64 defconfig
make ARCH=arm64 modules_prepare
# Then uncomment the source tree paths in c_cpp_properties.json
```

### On MS-A2 (WSL, cross-compilation)

```bash
# After building with Yocto, extract the SDK
kas shell yocto/kas/rpi4.yml -c "bitbake -c populate_sdk core-image-minimal"
# Then uncomment the SDK paths in c_cpp_properties.json
```

## Tasks

`Ctrl+Shift+B` opens the build task picker:

| Task | What it does |
|------|-------------|
| Buildroot: build RPi4 | `make buildroot-rpi4` (tmpfs) |
| Yocto: build RPi4 | `make yocto-rpi4` (kas) |
| Kernel module: build | Builds the module in the current directory |
| Flash RPi4 | Prompts for device, flashes SD |
| Collect RPi4 logs | SSH to RPi4, collect dmesg + /proc |
| Journal: create today | `make journal` |
| Pre-push check | Runs `prepush_check.sh` |

## Remote-SSH to CM3588

1. Install "Remote - SSH" extension
2. `Ctrl+Shift+P` → "Remote-SSH: Connect to Host..."
3. Enter: `vincent@cm3588.local` (or IP)
4. Open the repo folder on the CM3588
5. VSCode installs its server component automatically

The workspace settings, tasks, and IntelliSense all work transparently over SSH.

## Workspaces

For multi-root (repo + kernel source), create a `.code-workspace` file:

```json
{
    "folders": [
        { "path": "." },
        { "path": "../sources/linux-rpi", "name": "Linux kernel" }
    ]
}
```

This gives you F12 navigation from your module code into kernel source.
