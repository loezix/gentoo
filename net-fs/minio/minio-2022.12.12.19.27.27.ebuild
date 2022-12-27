# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module systemd

MY_PV="$(ver_cut 1-3)T$(ver_cut 4-7)Z"
MY_PV=${MY_PV//./-}

DESCRIPTION="An Amazon S3 compatible object storage server"
HOMEPAGE="https://github.com/minio/minio"
SRC_URI="https://github.com/minio/minio/archive/RELEASE.${MY_PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/loezix/gentoo-repo/releases/download/go-deps/${PN}-${PV}-deps.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~riscv ~amd64-linux"

RESTRICT="test"

DEPEND="
	acct-user/minio
	acct-group/minio
"

S="${WORKDIR}/${PN}-RELEASE.${MY_PV}"

src_prepare() {
    default
    sed -i -e "s/+ commitID().*// " buildscripts/gen-ldflags.go || die
}


src_compile() {
    MINIO_RELEASE="${MY_PV}"
    go build --ldflags "$(go run buildscripts/gen-ldflags.go ${MY_PV})"
}

src_install() {
	dobin minio

	insinto /etc/default
	newins "${FILESDIR}/minio" minio.default

	insinto /etc/conf.d
	doins "${FILESDIR}/minio"

	dodoc -r README.md CONTRIBUTING.md docs

	systemd_dounit "${FILESDIR}"/minio.service
	newinitd "${FILESDIR}"/minio.initd minio

	keepdir /var/{lib,log}/minio
	fowners minio:minio /var/{lib,log}/minio
}
