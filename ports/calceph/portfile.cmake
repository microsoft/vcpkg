vcpkg_download_distfile(ARCHIVE
    URLS "https://www.imcce.fr/content/medias/recherche/equipes/asd/calceph/calceph-${VERSION}.tar.gz"
    FILENAME "calceph-${VERSION}.tar.gz"
    SHA512 1b03bc62ab32ab56a95ca33612824a1f2104a8cca225b6cbedc656655ab4477a922053257341f36b95792f002b39cbee6a1dd2522cacdac36282aa044e121d86
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

vcpkg_install_copyright(
    COMMENT "The CALCEPH library is triple-licensed (CECILL-2.1 OR CECILL-B OR CECILL-C)."
    FILE_LIST
        "${SOURCE_PATH}/COPYING_CECILL_V2.1.LIB"
        "${SOURCE_PATH}/COPYING_CECILL_B.LIB"
        "${SOURCE_PATH}/COPYING_CECILL_C.LIB"
)
