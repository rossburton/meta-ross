do_wipe_libtool () {
	find ${D} -type f -name "*.la" -exec rm \{} \;
}

addtask wipe_libtool after do_install before populate_sysroot do_package