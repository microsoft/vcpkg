vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ddtdanilo/LMDB-wrapper-MISRA-C
    REF "v${VERSION}"
    SHA512 d95e5cde169064cc408373be72c795de14f47684b32e97d60a5bb828e2f257e4848a32abe342d4d61ce5d103263442bc6672e84c4beaa6e90146d6a40961667e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLMDB_WRAPPER_BUILD_TESTS=OFF
        -DLMDB_WRAPPER_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_build()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME lmdb_wrapper CONFIG_PATH lib/cmake/lmdb_wrapper)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
