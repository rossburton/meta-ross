addtask cvecheck

# TODO: add depends on cve-check-tool-native
# TODO: add task to inspect all recipes in a single call

python do_cvecheck() {
    import csv, re, tempfile, subprocess, StringIO

    # Extract a list of patches which look like CVE fixes
    patches = []
    for url in src_patches(d):
        name = os.path.basename(bb.fetch.decodeurl(url)[2])
        m = re.search(r"cve-\d+-\d+", name, re.IGNORECASE)
        if m:
            patches.append(m.group(0))

    # Write the faux CSV file for cve-check-tool to read
    (fd, faux) = tempfile.mkstemp(prefix="cve-faux-")
    with os.fdopen(fd, "w") as f:
        f.write("%s,%s,%s," % (d.getVar("BPN", True),
                               d.getVar("PV", True),
                               " ".join(patches)))

    output = subprocess.check_output(["cve-check-tool", "--no-html", "--csv", "--not-affected", "-t", "faux", faux])
    os.remove(faux)

    # Package, version, unpatched, patched
    for row in csv.reader(StringIO.StringIO(output)):
        if row[2]:
            bb.warn("%s: Unpatched CVEs: %s" % (row[0], row[2]))
}
do_cvecheck[nostamp] = "1"


addtask cvecheckall after do_cvecheck
do_cvecheckall[recrdeptask] = "do_cvecheckall do_cvecheck"
do_cvecheckall[recideptask] = "do_${BB_DEFAULT_TASK}"
do_cvecheckall() {
	:
}
