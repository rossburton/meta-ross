WIPE_LA ?= "1"

do_wipe_libtool() {
	if [ ${WIPE_LA} != 0 ]; then
		find "${D}" -name "*.la" -delete
	fi
}

do_install[postfuncs] += "do_wipe_libtool"
