SUMMARY = "Convert ninja logs to Chrome's tracing format"
HOMEPAGE = "https://github.com/nico/ninjatracing"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

#SRC_URI = "git://github.com/nico/ninjatracing;protocol=https;branch=main"

SRC_URI = "git://github.com/cradleapps/ninjatracing;protocol=https;branch=ninja_log_v7"
SRCREV = "084212eaf68f25c70579958a2ed67fb4ec2a9ca4"

do_install() {
    install -d ${D}${bindir}
    install ninjatracing ${D}${bindir}
}

RDEPENDS:${PN} = "python3-core python3-json "

BBCLASSEXTEND = "native nativesdk"
