do_configure[postfuncs] += "do_qa_more_configure"
python do_qa_more_configure() {
    import subprocess

    if bb.data.inherits_class("autotools", d):
        if "intltool-native" in d.getVar("DEPENDS", True):
            # TODO or configure.in
            ret = subprocess.call(['grep', '-q', "[AI][CT]_PROG_INTLTOOL", os.path.join(d.getVar("AUTOTOOLS_SCRIPT_PATH", True), "configure.ac")])
            if ret == 1:
                error_msg = "%s depends on intltool but doesn't use it" % d.getVar("PN", True)
                package_qa_handle_error("redundant-intltool", error_msg, d)
}

do_unpack[postfuncs] += "do_qa_more_unpack"
python do_qa_more_unpack() {
    bb.build.exec_func("do_check_debian_src", d)
}

WARN_QA_append = " redundant-intltool debian-mirror"

# This works on world!
addtask check_debian_src
do_check_debian_src[nostamp] = "1"
python do_check_debian_src() {
    if "${DEBIAN_MIRROR}" in d.getVar("SRC_URI", False):
        package_qa_handle_error("debian-mirror", "SRC_URI uses DEBIAN_MIRROR", d)
}
