def simplefeed_get_hostname(d):
    import socket
    return socket.gethostname()

SIMPLEFEED_HOSTNAME ?= "${@simplefeed_get_hostname(d)}"
SIMPLEFEED_PORT ?= "8000"

PACKAGE_FEED_URIS = "http://${SIMPLEFEED_HOSTNAME}:${SIMPLEFEED_PORT}/"

addtask simplefeed after do_deploy
do_simplefeed[depends] += "${PACKAGEINDEXDEPS}"
python do_simplefeed() {
    import os
    import http.server
    import socketserver
    import oe.rootfs

    bb.note("Generating package index")
    oe.rootfs.generate_index_files(d)

    pkg_class = d.getVar("PACKAGE_CLASSES").split()[0]
    var = "DEPLOY_DIR_" + pkg_class.replace("package_", "").upper()
    root = d.getVar(var)
    os.chdir(root)

    port = int(d.getVar("SIMPLEFEED_PORT"))
    handler = http.server.SimpleHTTPRequestHandler
    httpd = socketserver.TCPServer(("", port), handler)

    bb.plain("Starting server, control-c twice to stop.")
    httpd.serve_forever()
}
