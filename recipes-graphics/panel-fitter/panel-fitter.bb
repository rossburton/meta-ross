SUMMARY = "Set panel size"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "file://80panel-fitter"

RDEPENDS_${PN} = "intel-gpu-tools"

do_install() {
             install -d ${D}${sysconfdir}/X11/Xsession.d
             install -m 0755 ${WORKDIR}/80panel-fitter ${D}${sysconfdir}/X11/Xsession.d
}
