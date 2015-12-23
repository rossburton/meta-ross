addtask cvecheck
do_cvecheck[depends] += "cve-check-tool-native:do_populate_sysroot"

# TODO: add task to inspect all recipes in a single call
# TODO: let recipe override BPN for recipes where BPN isn't the right name

python do_cvecheck() {
    import csv, re, tempfile, subprocess, StringIO

    # Extract what looks like CVE IDs from the list of patches.  cve-check-tool
    # needs CVE-[year]-[id].
    potential = []
    for url in src_patches(d):
        name = os.path.basename(bb.fetch.decodeurl(url)[2])
        m = re.search(r"cve-\d+-\d+", name, re.IGNORECASE)
        if m:
            potential.append(m.group(0).upper())

    # Write the faux CSV file for cve-check-tool to read
    (fd, faux) = tempfile.mkstemp(prefix="cve-faux-")
    with os.fdopen(fd, "w") as f:
        f.write("%s,%s,%s," % (d.getVar("BPN", True),
                               d.getVar("PV", True),
                               " ".join(potential)))

    output = subprocess.check_output(["cve-check-tool", "--no-html", "--csv", "--not-affected", "-t", "faux", faux])
    os.remove(faux)

    # Package, version, unpatched, patched
    for row in csv.reader(StringIO.StringIO(output)):
        if row[2]:
            bb.warn("%s: Unpatched CVEs: %s" % (row[0], row[2]))
        if row[3]:
            bb.warn("%s: Patched CVEs: %s" % (row[0], row[3]))
}
do_cvecheck[nostamp] = "1"


addtask cvecheckall after do_cvecheck
do_cvecheckall[recrdeptask] = "do_cvecheckall do_cvecheck"
do_cvecheckall[recideptask] = "do_${BB_DEFAULT_TASK}"
do_cvecheckall() {
	:
}
