HOMEPAGE = "http://mesonbuild.com"
SUMMARY = "A high performance build system"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=3b83ef96387f14655fc854ddc3c6bd57"

#SRC_URI = "https://github.com/mesonbuild/meson/releases/download/${PV}/${BP}.tar.gz"
#SRC_URI[md5sum] = "ea2b5298e6a5013797cce83dcecbe47f"
#SRC_URI[sha256sum] = "2e8c06136da01607364cbcd8a719f0f60441a9a4c5f1426e88a3c6a8444331ac"

SRC_URI = "git://github.com/mesonbuild/meson"
SRCREV = "f3c793b9c1705f4eebbc68755bea7fe7926d123f"
S = "${WORKDIR}/git"

inherit setuptools3

# TODO need to add python3-modules-native to python3-native's RPROVIDES?  Needs to be auto-generated.
#RDEPENDS_${PN} += "python3-core python3-modules"

RDEPENDS_${PN} = "ninja"

BBCLASSEXTEND = "native"
