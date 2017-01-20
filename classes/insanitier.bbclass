# TODO Rename
WARN_QA_append = " configure-depends libtool-wrapper"

addtask configure_qa_more after do_patch before do_build
python do_configure_qa_more() {
    if not bb.data.inherits_class("autotools", d):
        return

    def check_configure(*matches):
        import subprocess
        def expressions():
            for m in matches:
                yield "-e"
                yield m
        cmd = ['grep', '-q']
        cmd.extend(expressions())
        cmd.append(os.path.join(d.getVar("AUTOTOOLS_SCRIPT_PATH", True), "configure.ac"))
        cmd.append(os.path.join(d.getVar("AUTOTOOLS_SCRIPT_PATH", True), "configure.in"))
        return subprocess.call(cmd) == 0

    depends = d.getVar("DEPENDS", True).split()

    if "intltool-native" in depends:
        if not check_configure("[AI][CT]_PROG_INTLTOOL"):
            error_msg = "%s depends on intltool but doesn't use it" % d.getVar("PN", True)
            package_qa_handle_error("configure-depends", error_msg, d)

    uses_gnomecommon = check_configure("GNOME_COMPILE_WARNINGS", "GNOME_CXX_WARNINGS", "GNOME_MAINTAINER_MODE_DEFINES", "GNOME_CODE_COVERAGE")
    has_gnomecommon = "gnome-common" in depends or "gnome-common-native" in depends
    if has_gnomecommon and not uses_gnomecommon:
        error_msg = "%s depends on gnome-common but doesn't use it" % d.getVar("PN", True)
        package_qa_handle_error("configure-depends", error_msg, d)
    if uses_gnomecommon and not has_gnomecommon:
        error_msg = "%s needs to DEPEND on gnome-common" % d.getVar("PN", True)
        package_qa_handle_error("configure-depends", error_msg, d)
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


QAPATHTEST[libtool-wrapper] = "package_qa_check_libtool_wrapper"
def package_qa_check_libtool_wrapper(path, name, d, elf, messages):
    """
    Warn if there appears to be libtool wrapper scripts installed
    """
    if elf:
        return

    import errno, stat, subprocess

    try:
        statinfo = os.stat(path)
        if bool(statinfo.st_mode & stat.S_IXUSR):
            if subprocess.call("grep -q -F 'libtool wrapper (GNU libtool)' %s" % path, shell=True) == 0:
                package_qa_handle_error("libtool-wrapper", "%s looks like a libtool wrapper script" % path, d)
    except OSError as exc:
        if exc.errno != errno.ENOENT:
            raise
