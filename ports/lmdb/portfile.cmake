vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF "LMDB_${VERSION}"
    SHA512 e51013e4fcd375cacbda19ccd49998b2f4f0b59f6888b91bb6e6cff883ada80451137fd95fb5fb9a46ef4ea294fff75a54a81448af71ac654993b52de62f2374
    HEAD_REF master
    PATCHES
        getopt-win32.diff
        msvc.diff
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
