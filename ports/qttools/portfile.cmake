set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qt")
include("${SCRIPT_PATH}/qt_port_hashes.cmake")
include("${SCRIPT_PATH}/qt_install_copyright.cmake")

vcpkg_find_acquire_program(PERL) # Perl is probably required by all qt ports for syncqt
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})
vcpkg_find_acquire_program(PYTHON3) # Perl is probably required by all qt ports for syncqt
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_PATH})

set(${PORT}_PATCHES)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/${PORT}
    REF ${${PORT}_REF}
    SHA512 ${${PORT}_HASH}
    HEAD_REF master
    PATCHES ${${PORT}_PATCHES}
)

# General features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    # "appstore-compliant"  QT_FEATURE_appstore-compliant
    # )

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS 
        ${FEATURE_OPTIONS}
        # Setup Qt syncqt (required for headers)
        -DHOST_PERL:PATH="${PERL}"
        -DQT_SYNCQT:PATH="${CURRENT_INSTALLED_DIR}/tools/qtbase/syncqt.pl"
        -DINSTALL_DESCRIPTIONSDIR:STRING="modules"
        -DINSTALL_LIBEXECDIR:STRING="bin"
        -DINSTALL_PLUGINSDIR:STRING="plugins"
        -DINSTALL_QMLDIR:STRING="qml"
        -DINSTALL_TRANSLATIONSDIR:STRING="translations"
    OPTIONS_RELEASE
        -DINPUT_release:BOOL=ON
    OPTIONS_DEBUG
        -DINPUT_debug:BOOL=ON
        -DINSTALL_DOCDIR:STRING="../doc"
        -DINSTALL_INCLUDEDIR:STRING="../include"
)
vcpkg_install_cmake(ADD_BIN_TO_PATH)
vcpkg_copy_pdbs()

set(COMPONENTS
    )

foreach(_comp IN LISTS COMPONENTS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/share/Qt6${_comp}")
        vcpkg_fixup_cmake_targets(CONFIG_PATH share/Qt6${_comp} TARGET_PATH share/Qt6${_comp})
        # Would rather put it into share/cmake as before but the import_prefix correction in vcpkg_fixup_cmake_targets is working against that. 
    else()
        message(STATUS "WARNING: Qt component ${_comp} not found/built!")
    endif()
endforeach()

 set(TOOL_NAMES 
    )
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/mkspecs"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/lib/cmake/"
                    )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
endif()

qt_install_copyright("${SOURCE_PATH}")