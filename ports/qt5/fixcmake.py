import os
import re
from glob import glob

files = [y for x in os.walk('.') for y in glob(os.path.join(x[0], '*.cmake'))]

for f in files:
    openedfile = open(f, "r")
    builder = ""
    exepattern = re.compile("_install_prefix}/bin/[a-z]+.exe")
    for line in openedfile:
        if "_install_prefix}/bin/${LIB_LOCATION}" in line:
            builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            builder += "\n    " + line
            builder += "    else()"
            builder += "\n    " + line.replace("/bin/", "/debug/bin/")
            builder += "    endif()\n"
        elif "_install_prefix}/lib/${LIB_LOCATION}" in line:
            builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            builder += "\n    " + line
            builder += "    else()"
            builder += "\n    " + line.replace("/lib/", "/debug/lib/")
            builder += "    endif()\n"
        elif "_install_prefix}/lib/${IMPLIB_LOCATION}" in line:
            builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            builder += "\n    " + line
            builder += "    else()"
            builder += "\n    " + line.replace("/lib/", "/debug/lib/")
            builder += "    endif()\n"
        elif "_install_prefix}/lib/qtmaind.lib" in line:
            builder += line.replace("/lib/", "/debug/lib/")
        elif "_install_prefix}/plugins/${PLUGIN_LOCATION}" in line:
            builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            builder += "\n    " + line
            builder += "    else()"
            builder += "\n    " + line.replace("/plugins/", "/debug/plugins/")
            builder += "    endif()\n"
        elif exepattern.search(line) != None:
            builder += line.replace("/bin/", "/tools/")
        else:
            builder += line
    new_file = open(f, "w")
    new_file.write(builder)
    new_file.close()