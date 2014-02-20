addtask datadiver
do_datadiver[nostamp] = "1"
python do_datadiver() {
    import os; os.environ['DISPLAY'] = d.getVar("BB_ORIGENV", False).getVar("DISPLAY", True)
    from gi.repository import Gtk, Pango

    # TODO: when this is wrapped in my GTK+, but done properly
    #GLib.log_set_default_handler(lambda domain, level, message, data: bb.plain(message))

    class DataDiverWindow(Gtk.Window):
        def __init__(self):
            Gtk.Window.__init__(self, title="Data Diver")
            # TODO: columns for each of the major flags (task, func, python)
            self.keystore = Gtk.ListStore(str)
            self.keystore.set_sort_column_id(0, Gtk.SortType.ASCENDING)

            pane = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
            pane.show()
            self.add(pane)

            frame = Gtk.Frame(shadow_type=Gtk.ShadowType.IN)
            frame.show()
            pane.add1(frame)

            scrolled = Gtk.ScrolledWindow()
            scrolled.show()
            frame.add(scrolled)

            self.keylist = Gtk.TreeView(model=self.keystore)
            self.keylist.set_enable_search(True)
            self.keylist.set_search_column(0)
            self.keylist.set_headers_visible(False)
            def key_search(model, column, key, treeiter, search_data):
              if key.lower() in model[treeiter][0].lower():
                  return 0
              return -1
            self.keylist.set_search_equal_func(key_search, None)
            column = Gtk.TreeViewColumn("Title", Gtk.CellRendererText(), text=0)
            # TODO: show icons for the flags
            self.keylist.append_column(column)
            self.keylist.get_selection().connect("changed", self.on_keylist_changed)
            # TODO: add a search bar with options also in the bar to filter on flags
            self.keylist.show()
            scrolled.add(self.keylist)


            frame = Gtk.Frame(shadow_type=Gtk.ShadowType.IN)
            frame.show()
            pane.add2(frame)

            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            box.show()
            frame.add(box)

            self.label = Gtk.Label()
            self.label.set_alignment(0.0, 0.0)
            self.label.show()
            box.pack_start(self.label, False, False, 0)

            scrolled = Gtk.ScrolledWindow(shadow_type=Gtk.ShadowType.IN)
            scrolled.show()
            box.pack_start(scrolled, True, True, 0)

            self.value_buffer = Gtk.TextBuffer()
            valueview = Gtk.TextView(buffer=self.value_buffer)
            valueview.set_editable(False)
            valueview.override_font(Pango.FontDescription.from_string("monospace"))
            valueview.show()
            scrolled.add(valueview)

            self.value_expand_check = Gtk.CheckButton(label="Expand variables")
            self.value_expand_check.show()
            self.value_expand_check.connect("toggled", self.on_expand_toggled)
            box.add(self.value_expand_check)

        def on_expand_toggled(self, check):
            model, treeiter = self.keylist.get_selection().get_selected()
            if treeiter:
                varname = model[treeiter][0]
                self.value_buffer.set_text(d.getVar(varname, check.get_active()))

        def on_keylist_changed(self, selection):
            model, treeiter = selection.get_selected()
            if treeiter is not None:
                varname = model[treeiter][0]
                s = "<big><b>%s</b></big>\n" % varname

                doc = d.getVarFlag(varname, "doc")
                if doc:
                    s += "<i>%s</i>\n" % doc

                s += "<b>Flags</b>\n"
                for flagname in d.getVarFlags(varname):
                  if flagname in ('doc',):
                      continue
                  flagvalue = d.getVarFlag(varname, flagname)
                  s += "- %s=%s\n" % (flagname, flagvalue)
                self.label.set_markup(s)

                self.value_expand_check.set_active(False)
                self.on_expand_toggled(self.value_expand_check)
            else:
                self.label.set_text("")
                self.value_buffer.set_text("")

    win = DataDiverWindow()
    win.connect("delete-event", Gtk.main_quit)

    for k in d.keys():
        # TODO: Just tasks for now, all of them later
        if d.getVarFlag(k, "task"):
            win.keystore.append([k,])

    win.show()
    Gtk.main()
}
