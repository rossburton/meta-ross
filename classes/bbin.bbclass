python process_bbin() {
    import os.path
    import string
    import urllib.parse

    # BIG TODO:
    # If the template uses a variable that the recipe otherwise doesn't touch,
    # the hash generation doesn't know.
    # anonpy to get the file from SRC_URI directly, using a dummy data object that tracks what names are __getitem__'d?
    
    # string.Template expects d[foo] to work, but data_smart does
    # d.getVar(expand=False) in that case so use an adapter object.
    class DataExpander():
        def __init__(self, d):
            self.d = d

        def __getitem__(self, name):
            return self.d.getVar(name)

    # Custom template instance that uses @ instead of $ to avoid having
    # to escape shell scripts.
    class Template(string.Template):
        delimiter = "@"

    src_uri = (d.getVar('SRC_URI') or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    fetchdata = fetcher.ud.values()
    fetchdata = (f for f in fetchdata if f.type == "file")
    fetchdata = (f for f in fetchdata if os.path.splitext(f.basename)[1] == ".bbin")

    for data in fetchdata:
        inputname = os.path.join(d.getVar("WORKDIR"), data.basename)
        outputname = os.path.splitext(inputname)[0]

        with open(inputname) as in_file:
            template = in_file.read()
            output = Template(template).substitute(DataExpander(d))
            with open(outputname, "w") as out_file:
                out_file.write(output)
}

do_unpack[postfuncs] += "process_bbin"
