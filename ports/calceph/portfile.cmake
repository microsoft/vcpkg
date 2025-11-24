vcpkg_download_distfile(ARCHIVE
    URLS "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-${VERSION}.tar.gz"
    FILENAME "calceph-${VERSION}.tar.gz"
    SHA512 d3f17a302dafee243a3c7698dd5b7e67550ba070cd3217c399e2cee5f90486d2be394ddcfe6dcc1b72f980e212d19bda50c4057fca05b032f6558794f191935a
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        disable-gnu-source.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    	-DENABLE_FORTRAN=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES calceph_inspector calceph_queryposition calceph_queryorientation AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/calceph" RENAME readme.rst)
vcpkg_install_copyright(
    COMMENT "The CALCEPH library is triple-licensed (CECILL-2.1 OR CECILL-B OR CECILL-C)."
    FILE_LIST
        "${SOURCE_PATH}/COPYING_CECILL_V2.1.LIB"
        "${SOURCE_PATH}/COPYING_CECILL_B.LIB"
        "${SOURCE_PATH}/COPYING_CECILL_C.LIB"
)
