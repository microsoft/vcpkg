vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF "LMDB_${VERSION}"
    SHA512 a5763ff94af0b5bbc2406c52890797e6232e77593bacdb240441ed30c8634e4e6de6eba206880475544e21561ccd0be2dee16733d6ec35483eb1dbbb81913a8d
    HEAD_REF master
    PATCHES
        getopt-win32.diff
)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/cmake/" DESTINATION "${SOURCE_PATH}/libraries/liblmdb")

vcpkg_check_features(OUT_FEATURE_OPTIONS options_release
    FEATURES
        tools   LMDB_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libraries/liblmdb"
    OPTIONS
        "-DLMDB_VERSION=${VERSION}"
    OPTIONS_RELEASE
        ${options_release}
    OPTIONS_DEBUG
        -DLMDB_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lmdb)

if(LMDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES mdb_copy mdb_dump mdb_load mdb_stat AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CURRENT_PORT_DIR}/lmdb-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/libraries/liblmdb/COPYRIGHT"
        "${SOURCE_PATH}/libraries/liblmdb/LICENSE"
)
