set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

#make sure your <vcpkg_root> path is really short! Otherwise the build will probably fail. 
# or maybe try to switch the build to nmake. 
#set(ENV{CMAKE_BUILD_PARALLEL_LEVEL} 1)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
