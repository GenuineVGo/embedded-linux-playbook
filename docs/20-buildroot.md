# Buildroot

## Build en tmpfs (défaut)

Le build Buildroot tourne dans `/dev/shm` (tmpfs, monté automatiquement, ~50% RAM). Un build complet RPi4 occupe 3–8 Go — largement dans les 16 Go disponibles sur le CM3588 (ou 23 Go sur MS-A2 WSL).

Le gain : I/O en RAM au lieu du NVMe/eMMC. Extraction, copie rootfs, génération d'image — tout ce qui est I/O-bound va 2–3x plus vite.

Le risque : un reboot perd l'arbre `output/`. Acceptable car le build est reconstituable en 30–45 min grâce au BR2_EXTERNAL versionné et au `DL_DIR` sur disque persistant.

```bash
# Via le Makefile (tout est configuré)
make buildroot-rpi4

# Équivalent manuel
make O=/dev/shm/buildroot-build \
     BR2_EXTERNAL=/path/to/embedded-linux-playbook/buildroot/external \
     BR2_DL_DIR=$HOME/buildroot-dl \
     raspberrypi4_64_defconfig
make O=/dev/shm/buildroot-build BR2_DL_DIR=$HOME/buildroot-dl -j$(nproc)
```

Séparation des données :
- `O=/dev/shm/buildroot-build` : arbre de build complet (tmpfs, volatile)
- `BR2_DL_DIR=$HOME/buildroot-dl` : archives sources téléchargées (disque, persistant)

## BR2_EXTERNAL

```bash
# Phase 0 : defconfig officiel Buildroot
make O=/dev/shm/buildroot-build \
     BR2_EXTERNAL=/path/to/embedded-linux-playbook/buildroot/external \
     BR2_DL_DIR=$HOME/buildroot-dl \
     raspberrypi4_64_defconfig

# Après customisation (menuconfig) : sauvegarder en defconfig custom
make O=/dev/shm/buildroot-build \
     savedefconfig BR2_DEFCONFIG=/path/to/embedded-linux-playbook/buildroot/external/configs/rpi4_64_defconfig
# Puis basculer le Makefile sur ton defconfig custom
```

*Content will grow with Phase 0 and Phase 2.*
