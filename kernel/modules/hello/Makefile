# Out-of-tree kernel module Makefile
# Usage:
#   make KDIR=/path/to/kernel/build
#   make KDIR=/path/to/kernel/build clean

obj-m := hello.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
