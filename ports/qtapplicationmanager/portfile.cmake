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
               appman-launcher-qml
               package-uploader
    )

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)
set(build_type_backup ${VCPKG_BUILD_TYPE})
set(path_backup "$ENV{PATH}")
if(NOT VCPKG_BUILD_TYPE)
  set(types release debug)
else()
  set(types ${VCPKG_BUILD_TYPE})
endif()
foreach(VCPKG_BUILD_TYPE IN LISTS types)
    if(VCPKG_BUILD_TYPE STREQUAL debug)
        vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/debug/bin")
    else()
        vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin")
    endif()
    qt_cmake_configure(${_opt} 
                       DISABLE_PARALLEL_CONFIGURE
                       OPTIONS
                            -DINPUT_libarchive=system
                            -DINPUT_libyaml=system
                            -DFEATURE_am_system_libyaml=ON
                            -DFEATURE_am_system_libarchive=ON
                       OPTIONS_DEBUG
                       OPTIONS_RELEASE)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(scriptfile "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tools/dumpqmltypes/CMakeFiles/appman-dumpqmltypes.dir/post-build.bat")
        file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" CURRENT_INSTALLED_DIR_NATIVE)
        if(EXISTS "${scriptfile}")
            vcpkg_replace_string("${scriptfile}" "${CURRENT_INSTALLED_DIR_NATIVE}\\bin" "${CURRENT_INSTALLED_DIR_NATIVE}\\debug\\bin")
        endif()
    endif()
    vcpkg_cmake_install()
    set(ENV{PATH} "${path_backup}")
endforeach()
set(VCPKG_BUILD_TYPE ${build_type_backup})
### Need to fix one post-build.bat; Couldn't find the place where it gets generated!

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
