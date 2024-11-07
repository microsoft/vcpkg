vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF "v${VERSION}"
    SHA512 3646ef80101570bddcbbd4d96a9d4d07377af370cfe75f48ae09024794e08db2d1ae2acbf3ceb9816d0701b92876f72a92e1d8201da3a7a47e0b5cb4f644f7b7
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZOE_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" ZOE_USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZOE_BUILD_SHARED_LIBS:BOOL=${ZOE_BUILD_SHARED_LIBS}
        -DZOE_USE_STATIC_CRT:BOOL=${ZOE_USE_STATIC_CRT}
        -DZOE_BUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/zoe)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
