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
   # dllpatterndebug = re.compile("_install_prefix}/bin/Qt5.*d+(.dll|.so)")
   # libpatterndebug = re.compile("_install_prefix}/lib/Qt5.*d+(.lib|.a)")
    exepattern = re.compile("_install_prefix}/bin/[a-z]+(.exe|)")
    toolexepattern = re.compile("_install_prefix}/tools/qt5/bin/[a-z]+(.exe|)")
    tooldllpattern = re.compile("_install_prefix}/tools/qt5/bin/Qt5.*d+(.dll|.so)")
   # populatepluginpattern = re.compile("_populate_[^_]+_plugin_properties\([^ ]+ RELEASE")
   # populatetargetpattern = re.compile("_populate_[^_]+_target_properties\(RELEASE ")
    for line in openedfile:
        if "_install_prefix}/tools/qt5/${LIB_LOCATION}" in line:
            builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            builder += "\n    " + line.replace("/tools/qt5/bin", "/bin/")
            builder += "    else()" #This requires a release and debug build since Qt will check that the file exists! 
            #It would be better to use an elseif here with a EXISTS check but that requires a more complicated regex to build the complete filepath since each module uses its own _(qtmodule)_install_prefix
            #so single configuration builds of Qt are currently not supported. Thus =>
            #TODO: Make single configuration builds of Qt work correctly!
            builder += "\n    " + line.replace("/tools/qt5/debug/bin", "/debug/bin/") 
            builder += "    endif()\n"
        # elif "_install_prefix}/bin/${LIB_LOCATION}" in line:
            # builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            # builder += "\n    " + line
            # builder += "    else()" #This requires a release and debug build!
            # builder += "\n    " + line.replace("/bin/", "/debug/bin/") 
            # builder += "    endif()\n"
        # elif "_install_prefix}/lib/${LIB_LOCATION}" in line:
            # builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            # builder += "\n    " + line
            # builder += "    else()" #This requires a release and debug build!
            # builder += "\n    " + line.replace("/lib/", "/debug/lib/")
            # builder += "    endif()\n"
        # elif "_install_prefix}/lib/${IMPLIB_LOCATION}" in line:
            # builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            # builder += "\n    " + line
            # builder += "    else()" #This requires a release and debug build!
            # builder += "\n    " + line.replace("/lib/", "/debug/lib/")
            # builder += "    endif()\n"
        # elif "_install_prefix}/plugins/${PLUGIN_LOCATION}" in line:
            # builder += "    if (${Configuration} STREQUAL \"RELEASE\")"
            # builder += "\n    " + line
            # builder += "    else()" #This requires a release and debug build!
            # builder += "\n    " + line.replace("/plugins/", "/debug/plugins/")
            # builder += "    endif()\n"
        elif "_install_prefix}/lib/qtmaind.lib" in line:
            # qtmaind.lib has been moved to manual-link:
            builder += line.replace("/lib/", "/debug/lib/manual-link/")
        elif "_install_prefix}/lib/qtmain.lib" in line:
            # qtmain(d).lib has been moved to manual-link:
            builder += line.replace("/lib/", "/lib/manual-link/")
            builder += "    set(imported_location_debug \"${_qt5Core_install_prefix}/debug/lib/manual-link/qtmaind.lib\")\n"
            builder += "\n"
            builder += "    set_target_properties(Qt5::WinMain PROPERTIES\n"
            builder += "        IMPORTED_LOCATION_DEBUG ${imported_location_debug}\n"
            builder += "    )\n"
        # elif populatepluginpattern.search(line) != None:
            # builder += line
            # builder += line.replace("RELEASE", "DEBUG").replace(".dll", "d.dll").replace(".lib", "d.lib")
        # elif populatetargetpattern.search(line) != None:
            # builder += line
            # builder += line.replace("RELEASE", "DEBUG").replace(".dll", "d.dll").replace(".lib", "d.lib")
        # elif dllpatterndebug.search(line) != None:
            # builder += line.replace("/bin/", "/debug/bin/")
        # elif libpatterndebug.search(line) != None:
            # builder += line.replace("/lib/", "/debug/lib/")
        elif tooldllpattern.search(line) != None:
            builder += line.replace("/tools/qt5/bin", "/debug/bin/")
        elif exepattern.search(line) != None:
            builder += line.replace("/bin/", tooldir)
        elif toolexepattern.search(line) != None:
            builder += line.replace("/tools/qt5/bin/",tooldir)
        else:
            builder += line
    new_file = open(f, "w")
    new_file.write(builder)
    new_file.close()
