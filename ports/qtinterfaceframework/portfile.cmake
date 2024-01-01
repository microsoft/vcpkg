set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES fix-taglib-search.patch # Strictly this is only required if qt does not use pkg-config since it forces it to off. 
                    )
set(TOOL_NAMES 
        ifmedia-simulation-server
        ifvehiclefunctions-simulation-server
    )

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()

if(_qis_DISABLE_NINJA)
    set(_opt DISABLE_NINJA)
endif()

vcpkg_find_acquire_program(PKGCONFIG)

x_vcpkg_get_python_packages(PYTHON_VERSION "3" 
                            REQUIREMENTS_FILE "${CURRENT_PORT_DIR}/requirements_minimal.txt" 
                            PACKAGES qface==2.0.5
                            OUT_PYTHON_VAR "PYTHON3")

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DVCPKG_HOST_TRIPLET=${_HOST_TRIPLET}")
endif()

set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)
qt_cmake_configure(${_opt} 
                   OPTIONS ${FEATURE_OPTIONS}
                        "-DPython3_EXECUTABLE=${PYTHON3}" # Otherwise a VS installation might be found. 
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_cmake_install(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

if(NOT VCPKG_CROSSCOMPILING)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/ifcodegen")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/ifcodegen" "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/ifcodegen")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Qt6/QtInterfaceFramework/${VERSION}/QtInterfaceFramework/private/qifqueryparser_flex_p.h" "${CURRENT_BUILDTREES_DIR}" "")
