SUMMARY = "Unigine Valley benchmark"
HOMEPAGE = "https://benchmark.unigine.com/valley"
# Non-commercial use only.  See the homepage for more details.
LICENSE = "CLOSED"

SRC_URI = "https://assets.unigine.com/d/Unigine_Valley-1.0.run"
SRC_URI[md5sum] = "186268c769db82f51a01cc8e0810752f"
SRC_URI[sha256sum] = "5f0c8bd2431118551182babbf5f1c20fb14e7a40789697240dcaf546443660f4"

COMPATIBLE_HOST = '(x86_64).*-linux'

DEPENDS = "patchelf-native"

do_install() {
    install -d ${D}/${libexecdir}/unigine-valley
    sh ${WORKDIR}/Unigine_Valley-1.0.run --nox11 --noexec --target ${D}/${libexecdir}/unigine-valley

    # Remove 32-bit binaries as we set COMPATIBLE_HOST to 64-bit IA above.
    rm -rf ${D}${libexecdir}/unigine-valley/bin/*x86*

    # Fix the interpreter path
    patchelf --set-interpreter ${base_libdir}/ld-linux-x86-64.so.2 ${D}${libexecdir}/unigine-valley/bin/browser_x64
}

RDEPENDS_${PN} = "bash fontconfig freetype libx11 libxext libxrandr libxrender libxinerama"

FILES_${PN} = "${libexecdir}/unigine-valley"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INSANE_SKIP_${PN} = "already-stripped"
