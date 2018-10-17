# Check that the rootfs doesn't have any broken links in

BROKEN_LINKS_FATAL ?= "0"

python image_qa_broken_links() {
    import os, os.path, oe.path
    from oe.utils import ImageQAFailed

    rootfs = d.getVar("IMAGE_ROOTFS")

    volatiles = [os.path.join(rootfs, d) for d in ("dev", "proc", "run", "var/volatile")]
    def is_volatile(path):
        for v in volatiles:
            if path.startswith(v):
                return True
        return False

    def follow(path):
        if is_volatile(path):
            return True    
        elif os.path.islink(path):
            target = os.readlink(path)
            if os.path.isabs(target):
                target = oe.path.join(rootfs, target)
            else:
                target = oe.path.join(os.path.dirname(path), target)
            return follow(target)
        else:
            return os.path.exists(path)

    failed = False
    for root, dirs, files in os.walk(rootfs):
        for f in files:
            path = os.path.join(root, f)
            if not follow(path):
                path = path.replace(rootfs, "")
                bb.warn("%s is a broken link" % (path))
                failed = True

    if failed and d.getVar("BROKEN_LINKS_FATAL") == "1":
        raise ImageQAFailed("Broken symbolic links found")
}
