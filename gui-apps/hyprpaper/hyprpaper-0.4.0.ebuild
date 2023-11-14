EAPI=8

inherit

DESCRIPTION="Hyprpaper is a blazing fast wayland wallpaper utility with IPC controls"
HOMEPAGE="https://github.com/hyprwm/hyprpaper"

SRC_URI="https://codeload.github.com/hyprwm/hyprpaper/tar.gz/refs/tags/v0.4.0 -> ${P}.tar.gz"

S="${WORKDIR}/${P}"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64"
BDEPEND="

"
RDEPEND="

"

DEPEND="
  ${RDEPEND}
"

src_compile() {
	emake protocols
	emake release
}

src_install() {
    dodir /usr/bin
	cp ${S}/build/${PN} ${D}/usr/bin/${PN} || die "Install Failed"
}
