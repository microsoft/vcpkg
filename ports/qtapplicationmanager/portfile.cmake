set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
        bump-cmake-version.patch
        wrapper-fixes.patch
        remove_post_build.patch
    )

set(TOOL_NAMES appman
               appman-controller
               appman-dumpqmltypes
               appman-packager
               appman-qmltestrunner
               appman-launcher-qml
               package-uploader
    )

file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/debug/bin" native_bin_dir)
file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/bin" native_bin_dir2) 
file(GET_RUNTIME_DEPENDENCIES 
        RESOLVED_DEPENDENCIES_VAR res_deps3
        UNRESOLVED_DEPENDENCIES_VAR unres_deps3
        EXECUTABLES "${CURRENT_INSTALLED_DIR}/tools/Qt6/bin/qmake${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        DIRECTORIES  "${native_bin_dir}" "${native_bin_dir2}"
    )
message(STATUS "res_deps3:${res_deps3}}\nunres_deps3:${unres_deps3}")

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
#vcpkg_cmake_install(ADD_BIN_TO_PATH)
vcpkg_cmake_build(ADD_BIN_TO_PATH TARGET appman-dumpqmltypes)

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/debug/bin")
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin")
file(GET_RUNTIME_DEPENDENCIES 
        RESOLVED_DEPENDENCIES_VAR res_deps
        UNRESOLVED_DEPENDENCIES_VAR unres_deps
        EXECUTABLES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/appman-dumpqmltypes${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        DIRECTORIES  "${native_bin_dir}"
    )
message(STATUS "res_deps:${res_deps}}\nunres_deps:${unres_deps}")
file(GET_RUNTIME_DEPENDENCIES 
        RESOLVED_DEPENDENCIES_VAR res_deps2
        UNRESOLVED_DEPENDENCIES_VAR unres_deps2
        EXECUTABLES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/appman-dumpqmltypes${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        DIRECTORIES  "${native_bin_dir}"
    )
message(FATAL_ERROR "res_deps2:${res_deps2}}\nunres_deps2:${unres_deps2}")
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
