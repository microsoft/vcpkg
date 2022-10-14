set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
        bump-cmake-version.patch
        wrapper-fixes.patch
        stack-walker-arm64.patch
    )

set(TOOL_NAMES appman
               appman-controller
               appman-dumpqmltypes
               appman-packager
               appman-qmltestrunner
               appman-launcher-qml
               package-uploader
    )

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)
qt_cmake_configure(${_opt} 
                   OPTIONS
                        -DINPUT_libarchive=system
                        -DINPUT_libyaml=system
                        -DFEATURE_am_system_libyaml=ON
                        -DFEATURE_am_system_libarchive=ON
                   OPTIONS_DEBUG
                   OPTIONS_RELEASE)

### Need to fix one post-build.bat; Couldn't find the place where it gets generated!
if(VCPKG_TARGET_IS_WINDOWS)
    set(scriptfile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tools/dumpqmltypes/CMakeFiles/appman-dumpqmltypes.dir/post-build.bat")
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" CURRENT_INSTALLED_DIR_NATIVE)
    if(EXISTS "${scriptfile}")
        vcpkg_replace_string("${scriptfile}" "${CURRENT_INSTALLED_DIR_NATIVE}\\bin" "${CURRENT_INSTALLED_DIR_NATIVE}\\debug\\bin")
    endif()
endif()
vcpkg_cmake_install(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

# Switch to a more complicated script due to the one post-build script which needed fixing after configure. 
# If somebody finds out how/where post-build.bat gets generated please fix it there instead.
#qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
#                     TOOL_NAMES ${TOOL_NAMES}
#                     CONFIGURE_OPTIONS
#                        --trace-expand
#                        -DINPUT_libarchive=system
#                        -DINPUT_libyaml=system
#                        -DFEATURE_am_system_libyaml=ON
#                        -DFEATURE_am_system_libarchive=ON
#                     CONFIGURE_OPTIONS_RELEASE
#                     CONFIGURE_OPTIONS_DEBUG
#                    )

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) #Debug tracing libraries are only build if CMAKE_BUILD_TYPE is equal to Debug
