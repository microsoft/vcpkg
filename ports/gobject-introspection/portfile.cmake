
set(GI_MAJOR_MINOR 1.70)
set(GI_PATCH 0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gobject-introspection/${GI_MAJOR_MINOR}/gobject-introspection-${GI_MAJOR_MINOR}.${GI_PATCH}.tar.xz"
    FILENAME "gobject-introspection-${GI_MAJOR_MINOR}.${GI_PATCH}.tar.xz"
    SHA512 216b376ed423f607e36c723dd6b67975dbfb63c253f2d8bd0b3661e3d69f8c8059cf221db8c5260b0262fad1b7d738f3b2e5fbd51fdbc31e40ccb115c209baf0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-g-ir-tool-template.in.patch
        0002-cross-build.patch
)

vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

set(OPTIONS_DEBUG -Dbuild_introspection_data=false)
set(OPTIONS_RELEASE -Dbuild_introspection_data=true)
if(NOT HOST_TRIPLET STREQUAL TARGET_TRIPLET AND
   NOT (CMAKE_HOST_WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86"))
    list(APPEND OPTIONS_RELEASE -Dgi_cross_use_prebuilt_gi=true)
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_NATIVE_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
    ADDITIONAL_CROSS_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
        g-ir-annotation-tool='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-annotation-tool'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner'
)

vcpkg_host_path_list(APPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
vcpkg_host_path_list(APPEND ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib")
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

set(GI_TOOLS
        g-ir-compiler
        g-ir-generate
        g-ir-inspect
)
set(GI_SCRIPTS
        g-ir-annotation-tool
        g-ir-scanner
)

vcpkg_copy_tools(TOOL_NAMES ${GI_TOOLS} AUTO_CLEAN)
foreach(script IN LISTS GI_SCRIPTS)
    file(READ "${CURRENT_PACKAGES_DIR}/bin/${script}" _contents)
    string(REPLACE "#!/usr/bin/env ${PYTHON3}" "#!/usr/bin/env python3" _contents "${_contents}")
    string(REPLACE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_INSTALLED_DIR}/lib" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}" "${_contents}")

    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) # _giscanner.lib
