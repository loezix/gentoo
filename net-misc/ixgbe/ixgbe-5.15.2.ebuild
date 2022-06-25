# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools dist-kernel-utils flag-o-matic linux-mod toolchain-funcs

DESCRIPTION="Linux*-based drivers for Intel® 10 Gigabit Ethernet Network Connections with PCI Express*."
HOMEPAGE="https://www.intel.com/content/www/us/en/download/14302/intel-network-adapter-driver-for-pcie-intel-10-gigabit-ethernet-network-connections-under-linux.html"
SRC_URI="https://sourceforge.net/projects/e1000/files/${PN}%20stable/${PV}/${PN}-${PV}.tar.gz/download"
LICENSE="GPL-2"
SLOT="0/${PVR}"
IUSE="custom-cflags debug +rootfs"



# PDEPEND in this form is needed to trick portage suggest
# enabling dist-kernel if only 1 package have it set
PDEPEND="dist-kernel? ( ~net-misc/${PN}-${PV}[dist-kernel] )"

RESTRICT="debug? ( strip ) test"

DOCS=( AUTHORS COPYRIGHT META README.md )

pkg_pretend() {
	use rootfs || return 0

	if has_version virtual/dist-kernel && ! use dist-kernel; then
		ewarn "You have virtual/dist-kernel installed, but"
		ewarn "USE=\"dist-kernel\" is not enabled for ${CATEGORY}/${PN}"
		ewarn "It's recommended to globally enable dist-kernel USE flag"
		ewarn "to auto-trigger initrd rebuilds with kernel updates"
	fi
}

pkg_setup() {
	CONFIG_CHECK="
		!DEBUG_LOCK_ALLOC
		EFI_PARTITION
		MODULES
		!PAX_KERNEXEC_PLUGIN_METHOD_OR
		!TRIM_UNUSED_KSYMS
		ZLIB_DEFLATE
		ZLIB_INFLATE
	"

	use debug && CONFIG_CHECK="${CONFIG_CHECK}
		FRAME_POINTER
		DEBUG_INFO
		!DEBUG_INFO_REDUCED
	"

	use rootfs && \
		CONFIG_CHECK="${CONFIG_CHECK}
			BLK_DEV_INITRD
			DEVTMPFS
	"

	kernel_is -lt 5 && CONFIG_CHECK="${CONFIG_CHECK} IOSCHED_NOOP"
	kernel_is -ge 3 10 || die "Linux 3.10 or newer required"

	linux-mod_pkg_setup
}

src_prepare() {
	default

	# Run unconditionally (bug #792627)
	eautoreconf
}

src_configure() {
	set_arch_to_kernel

	use custom-cflags || strip-flags

	filter-ldflags -Wl,*

	# Set CROSS_COMPILE in the environment.
	# This allows the user to override it via make.conf or via a local Makefile.
	# https://bugs.gentoo.org/811600
	export CROSS_COMPILE=${CROSS_COMPILE-${CHOST}-}

	econf
}

src_compile() {
	set_arch_to_kernel
	emake
}

src_install() {
	set_arch_to_kernel

	myemakeargs+=(
		DEPMOD=:
		# INSTALL_MOD_PATH ?= $(DESTDIR) in module/Makefile
		DESTDIR="${D}"
	)

	emake "${myemakeargs[@]}" install

	einstalldocs
}

pkg_postinst() {
	linux-mod_pkg_postinst
	if [[ -z ${ROOT} ]] && use dist-kernel; then
		set_arch_to_pkgmgr
		dist-kernel_reinstall_initramfs "${KV_DIR}" "${KV_FULL}"
	fi
}