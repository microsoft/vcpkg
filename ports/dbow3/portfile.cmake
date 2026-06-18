vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# https://github.com/rmsalinas/DBow3/pull/50 , already accepted but not merged as of 2023-06-13
vcpkg_download_distfile(REMOVE_DYNAMIC_EXCEPTION_SPECS
    URLS https://patch-diff.githubusercontent.com/raw/rmsalinas/DBow3/pull/50.patch?full_index=1
    SHA512 e39b9615aa8cfd4cf26b4ec977df823533b187d18ade5447c96fdcea53c9a58b1648e0a9fe78e3833360ba91c27ad56b6d65f944bd6c46f76969a652ba64cb5a
    FILENAME 9f9d19930c3ec597bd1ebc2a9c2a84b9fd49674e.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rmsalinas/DBow3
    REF c5ae539abddcef43ef64fa130555e2d521098369
    SHA512 a1b35d2a524a23c367180574f7ddbcad73161c7fda6c3e7973273ab86092d9c6d89df28925a8e53691cd894f2d6588832604a0dbdba478557695806907bf36eb
    PATCHES
        "${REMOVE_DYNAMIC_EXCEPTION_SPECS}"
        fix_cmake.patch
        add-cstdint.diff # https://github.com/rmsalinas/DBow3/pull/55
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_OPENCV_CONTRIB=ON
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake/DBow3)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
