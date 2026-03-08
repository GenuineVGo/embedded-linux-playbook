SUMMARY = "Install root SSH authorized_keys"
LICENSE = "CLOSED"

SRC_URI += "file://authorized_keys"

S = "${WORKDIR}"

do_install() {
    install -d -m 0700 ${D}/home/root/.ssh
    install -m 0600 ${WORKDIR}/authorized_keys ${D}/home/root/.ssh/authorized_keys
}

FILES:${PN} += "/home/root/.ssh/authorized_keys /home/root/.ssh"