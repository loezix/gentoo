# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson toolchain-funcs flag-o-matic linux-info linux-mod

DESCRIPTION="A set of libraries and drivers for fast packet processing"
HOMEPAGE="http://dpdk.org/"
SRC_URI="http://fast.${PN}.org/rel/${P}.tar.xz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug bpf cuda fastpath hpet iova-as-pa isa-l kmod lto numa ssl static-libs pgo xdp"

BDEPEND="
    bpf? ( dev-libs/libbpf )
    numa? ( sys-process/numactl:* )
	ssl? ( dev-libs/openssl:* )
	isa-l? ( dev-libs/isa-l )
	cuda? ( dev-util/nvidia-cuda-toolkit:* )
    xdp? ( net-libs/xdp-tools )
"
RDEPEND="${BDEPEND}"
DEPEND="
	${RDEPEND}
"

function ctarget() {
	CTARGET="${ARCH}"
	use amd64 && CTARGET='x86_64'
	echo $CTARGET
}

CONFIG_CHECK="~IOMMU_SUPPORT ~AMD_IOMMU ~VFIO ~VFIO_PCI ~UIO ~UIO_PDRV_GENIRQ ~UIO_DMEM_GENIRQ"
if [ "$SLOT" != "0" ] ; then
	S=${WORKDIR}/${PN}-${SLOT#0/}-${PV}
fi

pkg_setup() {
	linux-mod_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Ddefault_library=$(usex static-libs static shared)
		-Denable_iova_as_pa=$(usex iova-as-pa true false)
		-Denable_trace_fp=$(usex fastpath true false)
		-Denable_kmods=$(usex kmod true false)
		-Db_lto=$(usex lto true false)
		-Db_pgo=$(usex pgo use off)
		-Dc_args=$(usex cuda "-I/opt/cuda/include")
		-Duse_hpet=$(usex hpet true false)
	)
	meson_src_configure --buildtype=$(usex debug debug release)
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}
