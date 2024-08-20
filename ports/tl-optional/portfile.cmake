vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/optional
    REF c28fcf74d207fc667c4ed3dbae4c251ea551c8c1 # 2021-05-02
    SHA512 e5d5a6878903cb6641980f0fc68c4d94a59e3a8b0ad6a7f87abcc79ad7033e540045ce5ccd0e641ee924d43ba6df99e2b4ce2b04e1164ca9f47c660b8c2b2d48
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPTIONAL_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tl-optional)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
