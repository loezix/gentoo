# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools dist-kernel-utils flag-o-matic linux-mod toolchain-funcs
DESCRIPTION="Intel 10 Gigabit Ethernet Network Connections with PCI Express*."
HOMEPAGE="https://www.intel.com/content/www/us/en/download/14302/intel-network-adapter-driver-for-pcie-intel-10-gigabit-ethernet-network-connections-under-linux.html"
SRC_URI="https://ufpr.dl.sourceforge.net/project/e1000/${PN}%20stable/${PV}/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64"
SLOT="0"
IUSE="debug"

S=${WORKDIR}/${P}/src

pkg_setup() {
	linux-mod_pkg_setup
}

src_prepare() {
	default
	true
}

src_configure() {
	true
}

src_compile() {
	set_arch_to_kernel
	emake
}

src_install() {
	set_arch_to_kernel

	myemakeargs+=(
		DEPMOD=:
		DESTDIR="${D}"
	)

	emake "${myemakeargs[@]}" install
}

pkg_postinst() {
	linux-mod_pkg_postinst
	if [[ -z ${ROOT} ]] && use dist-kernel; then
		set_arch_to_pkgmgr
		dist-kernel_reinstall_initramfs "${KV_DIR}" "${KV_FULL}"
	fi
}
