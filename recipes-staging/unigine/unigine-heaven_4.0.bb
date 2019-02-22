SUMMARY = "Unigine Heaven benchmark"
HOMEPAGE = "https://benchmark.unigine.com/heaven"
# Non-commercial use only.  See the homepage for more details.
LICENSE = "CLOSED"

SRC_URI = "https://assets.unigine.com/d/Unigine_Heaven-4.0.run"
SRC_URI[md5sum] = "71e87df9f7b7569e9a2ea307fde2d8f4"
SRC_URI[sha256sum] = "1bb0204a9bd9b0bdbf2fe23aa0c32129905cb387040098b815332ddb396f36a7"

COMPATIBLE_HOST = '(x86_64).*-linux'

DEPENDS = "patchelf-native"

do_install() {
    install -d ${D}/${libexecdir}/unigine-heaven
    sh ${WORKDIR}/Unigine_Heaven-4.0.run --nox11 --noexec --target ${D}/${libexecdir}/unigine-heaven

    # Remove 32-bit binaries as we set COMPATIBLE_HOST to 64-bit IA above.
    rm -rf ${D}${libexecdir}/unigine-heaven/bin/*x86*

    # Fix the interpreter path
    patchelf --set-interpreter ${base_libdir}/ld-linux-x86-64.so.2 ${D}${libexecdir}/unigine-heaven/bin/browser_x64
}

RDEPENDS_${PN} = "bash fontconfig freetype libx11 libxext libxrandr libxrender libxinerama"

FILES_${PN} = "${libexecdir}/unigine-heaven"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} = "already-stripped"
