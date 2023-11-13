vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# The latest version of ZIMPL is included in the SCIP Optimization Suite.
set(scipoptsuite_version 8.0.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://scipopt.org/download/release/scipoptsuite-${scipoptsuite_version}.tgz"
    SHA512 46b56b3a4a5fcb4d6d53b5ffd9320bdf37fb55b9b8450a065312aa1e4f88863d3c563a495cf2622ef70a80132149c7b8f36cdb9a9e43906f4cfcafcb9dd6d606
    FILENAME "scipoptsuite-${scipoptsuite_version}.tgz"
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        libm.diff
        msvc.diff
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/zimpl"
    OPTIONS
        -DBREW=false
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=1
    MAYBE_UNUSED_VARIABLES
        BREW
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zimpl)
vcpkg_copy_tools(TOOL_NAMES zimpl AUTO_CLEAN)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/zimpl/zimpl-config.cmake" "../../../include" "../../include")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zimpl/mmlparse2.h" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/zimpl/" "")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/zimpl/LICENSE")
