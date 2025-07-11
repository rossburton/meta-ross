NINJATRACE_OUTPUT ?= "${WORKDIR}/${PN}.trace"

do_ninjatrace() {
    ninjatracing "${B}/.ninja_log" > "${NINJATRACE_OUTPUT}"
    bbplain "Wrote trace to ${NINJATRACE_OUTPUT}"
}
do_ninjatrace[depends] = "ninjatracing-native:do_populate_sysroot"
addtask ninjatrace after do_compile
