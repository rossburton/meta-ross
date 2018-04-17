WARN_QA_append_qemux86 = " lfs"

QAPATHTEST[lfs] = "package_qa_check_lfs"
def package_qa_check_lfs(path, pn, d, elf, messages):
    """
    Check that 32-bit binaries link to LFS-safe functions
    """
    # TODO check arch is 32-bit
    # TODO check distrofeatures has largefile in

    if not elf or not elf.isDynamic():
        return

    # TODO DO ONCE
    lfs = []
    for line in open(bb.utils.which(d.getVar("BBPATH"), "files/lfs-symbols")):
        line = line.strip()
        if not line or line[0] == '#':
            continue
        lfs.append(line)

    bad = []
    for symbol in elf.symbols():
        if symbol in lfs:
            bad.append(symbol)
    if bad:
        bb.warn("Found non-largefile symbols %s in %s" % (",".join(bad), path))
