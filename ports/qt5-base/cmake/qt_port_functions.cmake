list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

#Basic setup
include(qt_port_hashes)
#Fixup scripts
include(qt_fix_makefile_install)
include(qt_fix_cmake)
include(qt_fix_prl)
#Helper functions
include(qt_download_submodule)
include(qt_build_submodule)
include(qt_install_copyright)

include(qt_submodule_installation)
