addtask throwerror
do_throwerror[nostamp] = "1"
python do_throwerror() {
    bb.warn("About to crash...")
    raise RuntimeError("argh!")
}


addtask emiterror
do_emiterror[nostamp] = "1"
python do_emiterror() {
    bb.warn("this is a warning")
    bb.error("this is an error")
    bb.error("this is an error\non two lines")
}

addtask shellerror
do_shellerror() {
    set -x
    bbwarn This is a warning
    bberror This is an error
    bbfatal This is fatal
    bbwarn This should not appear
}
