python do_cve_count() {
    import contextlib, sqlite3

    product = d.getVar("CVE_PRODUCT")
    if not product:
        return

    with contextlib.closing(sqlite3.connect(d.getVar("CVE_CHECK_DB_FILE"))) as conn:
        cursor = conn.execute("SELECT ID FROM PRODUCTS WHERE PRODUCT = ?", (product,))
        count = len(cursor.fetchall())
        bb.warn("Found %d CVEs for %s" % (count, product))
}
addtask cve_count
do_cve_count[nostamp] = "1"
