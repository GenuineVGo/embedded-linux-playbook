################################################################################
#
# vincent-sensors — Custom I2C/SPI sensor drivers (Phase 3)
#
# TODO: Complete when driver code exists (Week 9+)
#
################################################################################

VINCENT_SENSORS_VERSION = 1.0
VINCENT_SENSORS_SITE = $(BR2_EXTERNAL_VINCENT_PATH)/../../kernel/modules
VINCENT_SENSORS_SITE_METHOD = local
VINCENT_SENSORS_LICENSE = GPL-2.0

# Kernel module: use the kernel-module infrastructure
# Uncomment when driver source is ready:
# VINCENT_SENSORS_MODULE_SUBDIRS = i2c-bme280 spi-mcp3008
# $(eval $(kernel-module))
# $(eval $(generic-package))
