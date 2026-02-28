/* hello.c — Phase 1 Week 1: Hello world kernel module
 *
 * SPDX-License-Identifier: GPL-2.0
 *
 * TODO (Week 1):
 * 1. Implement module_init / module_exit
 * 2. Add /proc entry
 * 3. Build out-of-tree, test on RPi4
 */

#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Vincent");
MODULE_DESCRIPTION("Hello world kernel module — learning exercise");

static int __init hello_init(void)
{
	pr_info("hello: module loaded\n");
	return 0;
}

static void __exit hello_exit(void)
{
	pr_info("hello: module unloaded\n");
}

module_init(hello_init);
module_exit(hello_exit);
