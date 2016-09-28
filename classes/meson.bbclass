inherit python3native

DEPENDS_append = " meson-native ninja-native"

# As Meson enforces out-of-tree builds we can just use cleandirs
B = "${WORKDIR}/build"
do_configure[cleandirs] = "${B}"

# Where the meson.build build configuration is
MESON_SOURCEPATH = "${S}"

# These variables in the environment override the *native* tools not the cross,
# so they need to be unexported.
CC[unexport] = "1"

addtask write_config before do_configure
do_write_config() {
    # This needs to be Py to split the args into single-element lists
    cat >${WORKDIR}/meson.cross <<EOF
[binaries]
c="${HOST_PREFIX}gcc"
ar="${HOST_PREFIX}ar"
[properties]
c_args=["${TOOLCHAIN_OPTIONS} ${HOST_CC_ARCH} ${CPPFLAGS} ${CFLAGS}"]
c_link_args=["${TOOLCHAIN_OPTIONS} ${HOST_LD_ARCH} ${LDFLAGS}"]
[host_machine]
system = 'linux'
cpu_family = 'arm'
cpu = 'arm'
endian = 'little'
EOF
}

meson_do_configure() {
    # TODO: arguments like EXTRA_OECONF
    if ! meson.py "${MESON_SOURCEPATH}" "${B}" --cross-file ${WORKDIR}/meson.cross; then
        cat ${B}/meson-logs/meson-log.txt
        bbfatal_log meson failed
    fi
}

meson_do_compile() {
    ninja
}

# TODO install

EXPORT_FUNCTIONS do_configure do_compile
