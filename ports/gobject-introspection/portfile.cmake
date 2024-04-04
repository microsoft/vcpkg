
set(GI_MAJOR_MINOR 1.72)
set(GI_PATCH 0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gobject-introspection/${GI_MAJOR_MINOR}/gobject-introspection-${GI_MAJOR_MINOR}.${GI_PATCH}.tar.xz"
    FILENAME "gobject-introspection-${GI_MAJOR_MINOR}.${GI_PATCH}.tar.xz"
    SHA512 b8fba2bd12e93776c55228acf3487bef36ee40b1abdc7f681b827780ac94a8bfa1f59b0c30d60fa5a1fea2f610de78b9e52029f411128067808f17eb6374cdc5
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-g-ir-tool-template.in.patch
        0002-cross-build.patch
        0003-fix-paths.patch
        python.patch
        fix-pkgconfig.patch
)

vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

set(OPTIONS_DEBUG -Dbuild_introspection_data=false)
if(VCPKG_CROSSCOMPILING)
    list(APPEND OPTIONS_RELEASE -Dgi_cross_use_prebuilt_gi=true)
    list(APPEND OPTIONS_RELEASE -Dbuild_introspection_data=false)
    # g-ir-scanner is not correctly setup for the cross build and
    # fails to correctly link against x86 libs (uses x64 instead)
else()
    list(APPEND OPTIONS_RELEASE -Dbuild_introspection_data=true)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        flex='${FLEX}'
        bison='${BISON}'
        g-ir-annotation-tool='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-annotation-tool'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-scanner'
        python='${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_host_path_list(APPEND ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
vcpkg_host_path_list(APPEND ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib")
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

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
    string(REPLACE "datadir = \"${CURRENT_PACKAGES_DIR}/share\"" "raise Exception('could not find right path') " _contents "${_contents}")
    string(REPLACE "pylibdir = os.path.join('${CURRENT_PACKAGES_DIR}/lib', 'gobject-introspection')" "raise Exception('could not find right path') " _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}" "${_contents}")

    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _pyd_lib_files "${CURRENT_PACKAGES_DIR}/lib/gobject-introspection/giscanner/_giscanner.*.lib")
    file(REMOVE ${_pyd_lib_files})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
