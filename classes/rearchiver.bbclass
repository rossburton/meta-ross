# Dumb source archiver that takes all the sources for a recipe and puts them in
# WORKDIR/archiver/.  Files in SRC_URI are copied directly, anything that's a
# directory (e.g. git repositories) is "unpacked" and then put into a tarball.

ARCHIVE_TEMPDIR = "${WORKDIR}/archiver/"
addtask rearchiver after do_fetch before do_build
do_rearchiver[cleandirs] = "${ARCHIVE_TEMPDIR}"

python do_rearchiver() {
    import shutil, tarfile, tempfile

    archive_tempdir = d.getVar("ARCHIVE_TEMPDIR", True)

    fetch = bb.fetch2.Fetch([], d)
    for url in fetch.urls:
        local = fetch.localpath(url)
        if os.path.isfile(local):
            shutil.copy(local, archive_tempdir)
        elif os.path.isdir(local):
            basename = os.path.basename(local)

            tmpdir = tempfile.mkdtemp(dir=archive_tempdir)
            fetch.unpack(tmpdir, (url,))

            os.chdir(tmpdir)
            tarname = os.path.join(archive_tempdir, basename + ".tar.gz")
            tar = tarfile.open(tarname, "w:gz")
            tar.add(".")
            tar.close()

            bb.utils.remove(tmpdir, recurse=True)
}
