################################################################################
#
# vincent-hello — Hello world kernel module (Phase 1)
#
################################################################################

VINCENT_HELLO_VERSION = 1.0
VINCENT_HELLO_SITE = $(BR2_EXTERNAL_VINCENT_PATH)/../../kernel/modules/hello
VINCENT_HELLO_SITE_METHOD = local
VINCENT_HELLO_LICENSE = GPL-2.0
VINCENT_HELLO_LICENSE_FILES = hello.c

# Kernel module: use the kernel-module infrastructure
$(eval $(kernel-module))
$(eval $(generic-package))
