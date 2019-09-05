#TODO summmary
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://COPYING;md5=2d5025d4aa3495befef8f17206a5b0a1"

SRC_URI = "https://github.com/tlwg/libdatrie/releases/download/v${PV}/${BP}.tar.xz"
SRC_URI[md5sum] = "b2243d583e25925200c134fad9f2fb50"
SRC_URI[sha256sum] = "452dcc4d3a96c01f80f7c291b42be11863cd1554ff78b93e110becce6e00b149"

# TODO upstream regex

DEPENDS = "autoconf-archive virtual/libiconv"

inherit autotools lib_package

EXTRA_OECONF = "--disable-doxygen-doc"

BBCLASSEXTEND = "native nativesdk"
