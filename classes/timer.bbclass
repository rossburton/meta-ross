python timer_handler () {
    import time, datetime, bb.event

    start_time = None

    if isinstance(e, bb.event.BuildStarted):
        t = datetime.datetime.fromtimestamp(int(time.time()))
        e.data.setVar("_time_starttime", t)

    elif isinstance(e, bb.event.BuildCompleted):
        start_time = e.data.getVar("_time_starttime")
        end_time = datetime.datetime.fromtimestamp(int(time.time()))
        duration = end_time - start_time

        bb.note("Build took %s minutes" % (duration))

    return
}

addhandler timer_handler
timer_handler[eventmask] = "bb.event.BuildStarted bb.event.BuildCompleted"
