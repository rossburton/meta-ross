WARN_QA_append = " configure-depends libtool-wrapper many-debug src-uri-bad podman"

do_configure[postfuncs] += "do_qa_configure_more"
python do_qa_configure_more() {
    if bb.data.inherits_class("autotools", d):
        def check_configure(*matches):
            import subprocess
            def expressions():
                for m in matches:
                    yield "-e"
                    yield m
            cmd = ['grep', '--quiet', '--no-messages']
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
        package_qa_add_message(messages, "stale-pyc", "%s: contains stale pyc %s" % (pn, package_qa_clean_path(path, d)))


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
                package_qa_handle_error("libtool-wrapper", "%s: %s looks like a libtool wrapper script" % (name, package_qa_clean_path(path, d, name)), d)
    except OSError as exc:
        if exc.errno != errno.ENOENT:
            raise

QARECIPETEST[many-debug] = "package_qa_check_many_debug"
def package_qa_check_many_debug(pn, d, messages):
    # If this is set then multiple -dbg packages are acceptable
    if d.getVar("NOAUTOPACKAGEDEBUG"):
        return

    # Package groups have a -dbg per package, so ignore those
    if bb.data.inherits_class("packagegroup", d):
        return

    seen = False
    for pkg in d.getVar("PACKAGES").split():
        if pkg.endswith("-dbg"):
            if seen:
                package_qa_handle_error("many-debug", "%s: has more than one -dbg package" % pn, d)
                return False
            seen = True
    return True

QARECIPETEST[src-uri-bad] = "package_qa_check_src_uri"
def package_qa_check_src_uri(pn, d, messages):
    import re

    srcuri = d.getVar("SRC_URI", False)
    if "${DEBIAN_MIRROR}" in srcuri:
        package_qa_handle_error("src-uri-bad", "%s: SRC_URI uses DEBIAN_MIRROR not archive.debian.org" % pn, d)
    if "${PN}" in srcuri:
        package_qa_handle_error("src-uri-bad", "%s: SRC_URI uses PN not BPN" % pn, d)
    if re.search(r"github\.com/.+/.+/archive/.*", srcuri):
        package_qa_handle_error("src-uri-bad", "%s: SRC_URI uses unstable github archives" % pn, d)

QAPKGTEST[missing-pn] = "package_qa_missing_pn"
def package_qa_missing_pn(pkg, d, messages):
    if d.getVar("PN") == pkg:
        pkg_dir = os.path.join(d.getVar('PKGDEST'), pkg)
        contents = set(os.listdir(pkg_dir))
        # strip out package database noise
        contents -= {'CONTROL', 'DEBIAN'}
        if len(contents) == 0 and d.getVar("ALLOW_EMPTY_" + pkg) != "1":
            package_qa_handle_error("missing-pn", "%s: primary package not generated" % pkg, d)

QAPATHTEST[podman] = "package_qa_check_podman"
def package_qa_check_podman(path, pkg, d, elf, messages):
    """
    Check that man pages don't contain pod2man versions
    """
    import re
    if pkg.endswith("-doc"):
        if d.getVar("mandir") in path:
            # TODO skip compressed files, or decompress them
            with open(path, errors="ignore") as f:
                line = f.readline()
                if re.search(r"Automatically generated by Pod::Man [0-9]+", line):
                    package_qa_add_message(messages, "podman", "%s contains non-reproducible man page %s" % (pkg, package_qa_clean_path(path, d, pkg)))
