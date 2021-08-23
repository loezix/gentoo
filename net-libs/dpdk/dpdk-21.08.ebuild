# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit meson toolchain-funcs flag-o-matic linux-info linux-mod

DESCRIPTION="A set of libraries and drivers for fast packet processing"
HOMEPAGE="http://dpdk.org/"
SRC_URI="http://fast.${PN}.org/rel/${P}.tar.xz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ssl static-libs"

DEPEND="
	sys-process/numactl
	ssl? ( dev-libs/openssl:* )
"
RDEPEND="${DEPEND}"
DEPEND="
	${DEPEND}
	!net-libs/dpdk:stable
	dev-lang/nasm
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
    cd "${S}" || die
	local mesonargs=(
		$(meson_feature static-libs default_library)
	) 	
	meson_src_configure
	
}

src_compile() {
	#cd "${S}/build" || die
	#ninja
	meson_src_compile
}

src_install() {
	#cd "${S}/build" || die
	#ninja install
    #ldconfig
	meson_src_install
	ldconfig
}