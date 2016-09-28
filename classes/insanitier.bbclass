WARN_QA_append = " redundant-intltool"

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

addtask srcuri_qa before do_build
python do_srcuri_qa() {
    srcuri = d.getVar("SRC_URI", False)

    if "${DEBIAN_MIRROR}" in srcuri:
        bb.warn("QA Issue: SRC_URI uses DEBIAN_MIRROR")

    if "${PN}" in srcuri:
        bb.warn("QA Issue: SRC_URI uses PN not BPN")
}

# TODO does not work for py3 (https://docs.python.org/3/whatsnew/3.2.html)
QAPATHTEST[stale-pyc] = "package_qa_check_stale_pyc"
def package_qa_check_stale_pyc(path, pn, d, elf, messages):
    """
    Check that the .pyc is not older than the corresponding .py
    """
    if not path.endswith(".pyc"):
        return

    import pathlib
    pycpath = pathlib.Path(path)
    pypath = pycpath.with_suffix(".py")
    if not pypath.exists():
        return

    if pycpath.stat().st_mtime < pypath.stat().st_mtime:
        # pn
        package_qa_add_message(messages, "stale-pyc", "package %s contains stale pyc %s" % (pn, package_qa_clean_path(path, d)))
