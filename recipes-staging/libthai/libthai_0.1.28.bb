#TODO summary

LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://COPYING;md5=2d5025d4aa3495befef8f17206a5b0a1"

SRC_URI = "https://github.com/tlwg/libthai/releases/download/v${PV}/${BP}.tar.xz"
SRC_URI[md5sum] = "aba40accba3831298d50b1b672dd2e68"
SRC_URI[sha256sum] = "ffe0a17b4b5aa11b153c15986800eca19f6c93a4025ffa5cf2cab2dcdf1ae911"

# TODO upstream regex

DEPENDS = "autoconf-archive libdatrie libdatrie-native"

inherit pkgconfig autotools

EXTRA_OECONF = "--disable-doxygen-doc"
