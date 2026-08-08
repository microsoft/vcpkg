vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF "LMDB_${VERSION}"
    SHA512 902908ca5fa66f8e2064ab44505f8172cd193c88c608a8369cc76e1285e9b36ef4c275f5b8ed21fd1ee31f0d7148a0050945dd0d5ea7cf74c24ada2f7c8d222d
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
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lmdb)
vcpkg_fixup_pkgconfig()

if(LMDB_BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES mdb_copy mdb_drop mdb_dump mdb_load mdb_stat AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/libraries/liblmdb/COPYRIGHT"
        "${SOURCE_PATH}/libraries/liblmdb/LICENSE"
)
