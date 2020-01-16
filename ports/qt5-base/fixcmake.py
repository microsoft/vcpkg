import os
import re
import sys
from glob import glob

port="qt5"
if len(sys.argv) > 1:
    port=sys.argv[1]

files = [y for x in os.walk('.') for y in glob(os.path.join(x[0], '*.cmake'))]
tooldir="/tools/"+port+"/bin/"

for f in files:
    openedfile = open(f, "r")
    builder = ""
    toolexepattern = re.compile("_install_prefix}/tools/qt5/bin/[a-z]+(.exe|)")
    for line in openedfile:
        if "_install_prefix}/lib/qtmain.lib" in line: # There is only one file which need to fix that
            print("qtmain")
            # qtmain(d).lib has been moved to manual-link:
            builder += line.replace("/lib/", "/lib/manual-link/")
            builder += "    set(imported_location_debug \"${_qt5Core_install_prefix}/debug/lib/manual-link/qtmaind.lib\")\n"
            builder += "\n"
            builder += "    if(EXISTS \"${imported_location_debug}\")"
            builder += "        set_target_properties(Qt5::WinMain PROPERTIES\n"
            builder += "            IMPORTED_LOCATION_DEBUG ${imported_location_debug}\n"
            builder += "        )\n"
            builder += "    endif()"
        elif toolexepattern.search(line) != None: # This could be avoided with a better copying of dll dependencies. 
            print("toolexepattern")
            builder += line.replace("/tools/qt5/bin/",tooldir)
        else:
            builder += line
    new_file = open(f, "w")
    new_file.write(builder)
    new_file.close()
