HOMEPAGE = "http://www.chiark.greenend.org.uk/ucgi/~ian/git/authbind.git/"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://debian/copyright;md5=6f17ef7d0fe03b28a52f4375c7ae3d2e"
SUMMARY = "Tool to allow non-root programs to bind() to low ports"

SRC_URI = "git://git.chiark.greenend.org.uk/~ian/authbind.git;tag=debian/${PV} \
           file://makefile.patch"

S = "${WORKDIR}/git"

EXTRA_OEMAKE = 'bin_dir=${bindir} lib_dir=${libdir} \
                libexec_dir=${libexecdir}/authbind share_dir=${datadir} \
                etc_dir=${sysconfdir}/authbind \
                LD="${LD} --hash-style=${LINKER_HASH_STYLE}"'


do_configure() {
	oe_runmake clean
}

do_compile () {
	oe_runmake
}

do_install () {
	install -D authbind ${D}${bindir}/authbind
	install -D libauthbind.so.1.0 ${D}${libdir}/libauthbind.so.1.0
	ln -sf libauthbind.so.1.0 ${D}${libdir}/libauthbind.so.1

	install -D -m 4755 helper ${D}${libexecdir}/authbind/helper

	install -d ${D}${sysconfdir}/byport ${D}${sysconfdir}/byaddr ${D}${sysconfdir}/byuid

	install -D authbind.1 ${D}${mandir}/man1/authbind.1
	install -D authbind-helper.8 ${D}${mandir}/man8/authbind-helper.8
}

EXCLUDE_FROM_WORLD = "1"
