vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WuKongIM/WuKongEasySDK-CPP
    REF "v${VERSION}"
    SHA512 b1e380e5bb67f34cf2f56d9b5c82b28f0d73167911edd9bfc77bbea6d4e29d62a8319a2f517110896c3ff457992897f7b4e6066469ed75716cd80750e2ae9939
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWUKONG_BUILD_TESTS=OFF
        -DWUKONG_BUILD_EXAMPLES=OFF
        -DWUKONG_FETCH_JSON=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME WuKongEasySDK CONFIG_PATH lib/cmake/WuKongEasySDK)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
