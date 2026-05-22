vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LMDB/lmdb
    REF 340f04593e3a05db615b3444fac9f3572ed75e3f # WIP 1.0.0 # "LMDB_${VERSION}"
    SHA512 b799dad2168dacac519864ab8f30de62aa1e445a5b6a5e5b3f197ee1d93e14e17f03f3b084265f9ef5567196f7755f2e35e0877392731f107da013b16613efc4
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
