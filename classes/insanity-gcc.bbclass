WARN_QA_append = " libgcc"

QAPATHTEST[libgcc] = "package_qa_check_libgcc"
def package_qa_check_libgcc(path, pn, d, elf, messages):
    if d.getVar("TCLIBC") != "glibc":
        return

    try:
        if not elf or not elf.isDynamic():
            return
        if "pthread_cancel" in elf.symbols():
            deps = bb.utils.explode_deps(d.getVar("RDEPENDS_" + pn))
            if "libgcc" not in deps:
                bb.warn("%s (%s) contains linkage to pthread_cancel but no dependency on libgcc" % (pn, os.path.basename(path)))
    except Exception as e:
        bb.warn("Cannot read ELF %s: %s" % (path, e))
