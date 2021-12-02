set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
        bump-cmake-version.patch
        wrapper-fixes.patch
    )

set(TOOL_NAMES appman
               appman-controller
               appman-dumpqmltypes
               appman-packager
               appman-qmltestrunner
               package-uploader
    )

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        -DINPUT_libarchive=system
                        -DINPUT_libyaml=system
                        -DFEATURE_am_system_libyaml=ON
                        -DFEATURE_am_system_libarchive=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) #Debug tracing libraries are only build if CMAKE_BUILD_TYPE is equal to Debug
