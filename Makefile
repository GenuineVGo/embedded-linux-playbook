# embedded-linux-playbook/Makefile
# Unified entry point for all builds and operations
#
# Local overrides: create local.mk (gitignored) with your paths:
#   BUILDROOT_SRC = ~/sources/buildroot
#   RPI_HOST = root@rpi4.local
#   FLASH_DEV = /dev/sdb
-include local.mk

BUILDROOT_SRC    ?= $(HOME)/buildroot
BUILDROOT_EXT    := $(CURDIR)/buildroot/external
BR2_OUT          ?= /dev/shm/buildroot-build
BR2_DL_DIR       ?= $(HOME)/buildroot-dl
# After customizing menuconfig, save your defconfig:
#   cd $BUILDROOT_SRC && make savedefconfig BR2_DEFCONFIG=$BUILDROOT_EXT/configs/rpi4_64_defconfig
# Then switch the Makefile target to use your custom defconfig.
YOCTO_KAS_DIR    := $(CURDIR)/yocto/kas
FLASH_DEV        ?= /dev/sdX
IMAGE            ?=
RPI_HOST         ?= root@rpi4.local

.PHONY: help buildroot-rpi4 yocto-rpi4 flash-rpi4 flash-buildroot-rpi4 flash-yocto-rpi4 \
        logs bootstrap-wsl bootstrap-debian journal find-images clean

help:
	@echo ""
	@echo "embedded-linux-playbook — available targets:"
	@echo ""
	@echo "  Build:"
	@echo "    buildroot-rpi4    Build Buildroot for RPi4 in tmpfs (BR2_OUT=/dev/shm/buildroot-build)"
	@echo "    yocto-rpi4        Build Yocto for RPi4 via kas (on MS-A2)"
	@echo ""
	@echo "  Deploy:"
	@echo "    flash-rpi4             Flash image (set FLASH_DEV + IMAGE)"
	@echo "    flash-buildroot-rpi4   Flash Buildroot image (auto-path from BR2_OUT)"
	@echo "    flash-yocto-rpi4       Flash Yocto image (auto-find .wic)"
	@echo "    logs                   Collect logs from RPi4 (set RPI_HOST=root@rpi4.local)"
	@echo ""
	@echo "  Setup:"
	@echo "    bootstrap-wsl     Install Yocto dependencies (WSL/Pengwin)"
	@echo "    bootstrap-debian  Install Buildroot dependencies (Debian/CM3588)"
	@echo ""
	@echo "  Workflow:"
	@echo "    journal           Create today's journal entry"
	@echo "    find-images       List available built images"
	@echo "    clean             Remove local build artifacts"
	@echo ""

# --- Build ---

buildroot-rpi4:
	@test -d $(BUILDROOT_SRC) || \
		(echo "ERROR: BUILDROOT_SRC=$(BUILDROOT_SRC) not found." && \
		 echo "Clone Buildroot first, then: make buildroot-rpi4 BUILDROOT_SRC=/path/to/buildroot" && \
		 exit 1)
	@mkdir -p $(BR2_OUT) $(BR2_DL_DIR)
	cd $(BUILDROOT_SRC) && \
	make O=$(BR2_OUT) BR2_EXTERNAL=$(BUILDROOT_EXT) BR2_DL_DIR=$(BR2_DL_DIR) raspberrypi4_64_defconfig && \
	make O=$(BR2_OUT) BR2_DL_DIR=$(BR2_DL_DIR) -j$$(nproc)
	@echo ""
	@echo "Build output: $(BR2_OUT)"
	@echo "Images:       $(BR2_OUT)/images/"
	@echo ""
	@echo "To save your customized config:"
	@echo "  cd $(BUILDROOT_SRC) && make O=$(BR2_OUT) savedefconfig BR2_DEFCONFIG=$(BUILDROOT_EXT)/configs/rpi4_64_defconfig"

yocto-rpi4:
	@command -v kas >/dev/null 2>&1 || \
		(echo "ERROR: kas not found. Install with: pip install kas --break-system-packages" && exit 1)
	kas build $(YOCTO_KAS_DIR)/rpi4.yml

# --- Deploy ---

flash-rpi4:
	@test -b $(FLASH_DEV) || \
		(echo "ERROR: FLASH_DEV=$(FLASH_DEV) is not a block device." && \
		 echo "Usage: make flash-rpi4 FLASH_DEV=/dev/sdX IMAGE=/path/to/image" && exit 1)
	@test -n "$(IMAGE)" || \
		(echo "ERROR: IMAGE not set." && \
		 echo "Usage: make flash-rpi4 FLASH_DEV=/dev/sdX IMAGE=/path/to/*.img|*.wic" && \
		 echo "" && \
		 echo "Hint: run 'make find-images' to list available images." && exit 1)
	scripts/flash_rpi4.sh $(FLASH_DEV) $(IMAGE)

flash-buildroot-rpi4:
	$(MAKE) flash-rpi4 IMAGE=$(BR2_OUT)/images/sdcard.img

flash-yocto-rpi4:
	$(MAKE) flash-rpi4 IMAGE=$$(find . -path '*/deploy/images/raspberrypi4-64/*.wic' -not -name '*.bz2' -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

logs:
	scripts/collect_logs.sh $(RPI_HOST)

# --- Setup ---

bootstrap-wsl:
	scripts/bootstrap_wsl.sh

bootstrap-debian:
	scripts/bootstrap_debian.sh

# --- Workflow ---

journal:
	@DATE=$$(date +%Y-%m-%d) && \
	FILE=journal/$$DATE.md && \
	if [ -f $$FILE ]; then \
		echo "Already exists: $$FILE"; \
	else \
		cp journal/_template.md $$FILE && \
		sed -i "s/YYYY-MM-DD/$$DATE/g" $$FILE && \
		echo "Created: $$FILE"; \
	fi

find-images:
	@echo "=== Buildroot images ==="
	@ls -lh $(BR2_OUT)/images/*.img $(BR2_OUT)/images/*.wic 2>/dev/null || echo "  (none — run: make buildroot-rpi4)"
	@echo ""
	@echo "=== Yocto images ==="
	@find . -path '*/deploy/images/raspberrypi4-64/*.wic*' -type f 2>/dev/null | sort || echo "  (none — run: make yocto-rpi4)"
	@echo ""
	@echo "Flash with: make flash-rpi4 FLASH_DEV=/dev/sdX"
	@echo "  or: scripts/flash_rpi4.sh /dev/sdX path/to/image"

clean:
	@echo "Cleaning local artifacts (not Yocto/Buildroot caches)"
	rm -f *.img *.wic *.wic.gz *.log
