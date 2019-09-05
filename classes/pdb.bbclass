def pdb():
  import bdb, rpdb, sys

  bb.warn("PDB on port 4444 started, waiting for connection...")
  try:
    rpdb.set_trace(frame=sys._getframe().f_back.f_back)
  except bdb.BdbQuit:
    pass

shell_wait() {
	FIFO="${WORKDIR}/wait-fifo"
	rm -f $FIFO
	/usr/bin/mkfifo $FIFO
	bbwarn Waiting for a write to $FIFO
	read foo <$FIFO
}
