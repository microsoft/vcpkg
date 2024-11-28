set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
        wrapper-fixes.patch
        stack-walker-arm64.patch
    )

set(TOOL_NAMES appman
               appman-controller
               appman-dumpqmltypes
               appman-packager
               appman-qmltestrunner
               appman-launcher-qml
               appman-package-server
               package-uploader
    )

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)
qt_cmake_configure(OPTIONS
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                        -DINPUT_libarchive='system'
                        -DINPUT_libyaml='system'
                        -DFEATURE_am_system_libyaml=ON
                        -DFEATURE_am_system_libarchive=ON
                        -DINPUT_libdbus='no'
                        -DINPUT_libbacktrace='no'
                        -DINPUT_systemd_watchdog='no'
                        -DINPUT_widgets_support=ON
                   TOOL_NAMES ${TOOL_NAMES}
)

### Need to fix one post-build.bat; Couldn't find the place where it gets generated!
if(VCPKG_TARGET_IS_WINDOWS)
    set(scriptfile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tools/dumpqmltypes/CMakeFiles/appman-dumpqmltypes.dir/post-build.bat")
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" CURRENT_INSTALLED_DIR_NATIVE)
    if(EXISTS "${scriptfile}")
        vcpkg_replace_string("${scriptfile}" "${CURRENT_INSTALLED_DIR_NATIVE}\\bin" "${CURRENT_INSTALLED_DIR_NATIVE}\\debug\\bin" IGNORE_UNCHANGED)
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


file(GLOB_RECURSE qttools "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/*")
if(NOT qttools AND VCPKG_CROSSCOMPILING)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/")
 endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CROSSCOMPILING AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin/"
        "${CURRENT_PACKAGES_DIR}/debug/bin/"
        "${CURRENT_PACKAGES_DIR}/tools/"
  )
endif()

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) #Debug tracing libraries are only build if CMAKE_BUILD_TYPE is equal to Debug
