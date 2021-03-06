addtask datadiver
do_datadiver[nostamp] = "1"
do_datadiver[vardepsexclude] = "BB_ORIGENV DISPLAY"

python do_datadiver() {
    import os; os.environ['DISPLAY'] = d.getVar("BB_ORIGENV", False).getVar("DISPLAY", True)
    from gi.repository import Gtk, Pango

    # TODO: when this is wrapped in my GTK+, but done properly
    #GLib.log_set_default_handler(lambda domain, level, message, data: bb.plain(message))

    class DataDiverWindow(Gtk.Window):
        def __init__(self):
            Gtk.Window.__init__(self, title="Data Diver")
            # TODO: columns for each of the major flags (task, func, python)
            # Variable name, is task, is func
            self.keystore = Gtk.ListStore(str, bool, bool)
            self.keystore.set_sort_column_id(0, Gtk.SortType.ASCENDING)
            self.filter = Gtk.TreeModelFilter(child_model=self.keystore)
            self.filter_column = None
            def filter_func(model, treeiter, nothing):
                if self.filter_column:
                    return model[treeiter][self.filter_column]
                return True
            self.filter.set_visible_func(filter_func)

            pane = Gtk.Paned(orientation=Gtk.Orientation.HORIZONTAL)
            pane.show()
            self.add(pane)

            frame = Gtk.Frame(shadow_type=Gtk.ShadowType.IN)
            frame.show()
            pane.add1(frame)

            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            box.show()
            frame.add(box)

            bbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            bbox.show()
            box.pack_start(bbox, False, False, 0)

            button = Gtk.RadioButton.new_with_label_from_widget(None, "All")
            button.connect("toggled", self.on_filter, None)
            button.show()
            bbox.add(button)

            button = Gtk.RadioButton.new_with_label_from_widget(button, "Tasks")
            button.connect("toggled", self.on_filter, 1)
            button.show()
            bbox.add(button)

            scrolled = Gtk.ScrolledWindow()
            scrolled.show()
            box.pack_start(scrolled, True, True, 0)

            self.keylist = Gtk.TreeView(model=self.filter)
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
            self.changed_id = self.keylist.get_selection().connect("changed", self.on_keylist_changed)
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
                self.value_buffer.set_text(d.getVar(varname, check.get_active()) or "")

        def on_filter(self, button, column):
            if not button.get_active():
                return

            self.filter_column = column

            # TODO: use with syntax when we have newer gobject
            selection = self.keylist.get_selection()
            selection.handler_block(self.changed_id)
            self.filter.refilter()
            selection.handler_unblock(self.changed_id)
            self.on_keylist_changed(selection)

        def on_keylist_changed(self, selection):
            model, treeiter = selection.get_selected()
            if treeiter is not None:
                varname = model[treeiter][0]
                s = "<big><b>%s</b></big>\n" % varname

                flags = d.getVarFlags(varname) or {}

                if "doc" in flags:
                    s += "<i>%s</i>\n" % flags["doc"]

                s += "<b>Flags</b>\n"
                # If there are no flags getVarFlags will return None instead of
                # an empty list.
                for flagname in flags:
                  if flagname in ('doc',):
                      continue
                  s += "- %s=%s\n" % (flagname, d.expand(flags[flagname]))
                self.label.set_markup(s)

                self.on_expand_toggled(self.value_expand_check)
            else:
                self.label.set_text("")
                self.value_buffer.set_text("")

    win = DataDiverWindow()
    win.connect("delete-event", Gtk.main_quit)

    for k in d.keys():
        flags = d.getVarFlags(k) or ()
        win.keystore.append([k, "task" in flags, "func" in flags])

    win.show()
    Gtk.main()
}
