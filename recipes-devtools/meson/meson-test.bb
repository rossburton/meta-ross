LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI = "https://github.com/mesonbuild/meson/releases/download/0.32.0/meson-0.32.0.tar.gz"
SRC_URI[md5sum] = "ea2b5298e6a5013797cce83dcecbe47f"
SRC_URI[sha256sum] = "2e8c06136da01607364cbcd8a719f0f60441a9a4c5f1426e88a3c6a8444331ac"

inherit pkgconfig meson

DEPENDS = "zlib"

S = "${WORKDIR}/meson-0.32.0/"
MESON_SOURCEPATH = "${S}/test cases/linuxlike/1 pkg-config"

BBCLASSEXTEND = "native"
