addtask crasher
do_crasher[nostamp] = "1"
python do_crasher() {
    bb.warn("About to crash...")
    raise RuntimeError("argh!")
}
