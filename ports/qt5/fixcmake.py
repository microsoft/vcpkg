import os
import re
from glob import glob

files = [y for x in os.walk('.') for y in glob(os.path.join(x[0], '*.cmake'))]

for f in files:
    openedfile = open(f, "r")
    builder = ""
    dllpattern = re.compile("_install_prefix}/bin/Qt5.*d.dll")
    libpattern = re.compile("_install_prefix}/lib/Qt5.*d.lib")
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
        elif "_install_prefix}/lib/qtmain.lib" in line:
            builder += line
            builder += "    set(imported_location_debug \"${_qt5Core_install_prefix}/debug/lib/qtmaind.lib\")\n"
            builder += "\n"
            builder += "    set_target_properties(Qt5::WinMain PROPERTIES\n"
            builder += "        IMPORTED_LOCATION_DEBUG ${imported_location_debug}\n"
            builder += "    )\n"
        elif dllpattern.search(line) != None:
            builder += line.replace("/bin/", "/debug/bin/")
        elif libpattern.search(line) != None:
            builder += line.replace("/lib/", "/debug/lib/")
        elif exepattern.search(line) != None:
            builder += line.replace("/bin/", "/tools/qt5/")
        else:
            builder += line
    new_file = open(f, "w")
    new_file.write(builder)
    new_file.close()