list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

# For mingw builds on Windows, establish a single msys root with perl.
if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_MINGW)
    vcpkg_acquire_msys(QT_MSYS_ROOT PACKAGES perl)
    vcpkg_add_to_path(PREPEND "${QT_MSYS_ROOT}/usr/bin")
    # Override vcpkg_find_acquire_program.
    find_program(PERL "perl" PATHS "${QT_MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
endif()

#Basic setup
include(qt_port_hashes)
if(QT_BUILD_LATEST) # only set in qt5-base
    include(qt_port_hashes_latest)
elseif(NOT PORT STREQUAL "qt5-base")
    include(qt_port_hashes_latest OPTIONAL) # will only be available for the other qt ports if qt5-base was build with latest
endif()
#Fixup scripts
include(qt_fix_makefile_install)
include(qt_fix_cmake)
include(qt_fix_prl)
#Helper functions
include(qt_download_submodule)
include(qt_build_submodule)
include(qt_install_copyright)

include(qt_submodule_installation)
