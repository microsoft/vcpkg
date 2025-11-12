vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO joanvallve/yaml-schema-cpp
    REF 24623cc5c4a5acb63dea9581ebcd84601bac1da1
    SHA512 d7622401ebce65b107eb363af88868fef4725c50ce0aa659a4510223275a3bc6b9d1fc1c71946247ea0142f7bc460f39c02f91e3c6466fdadacb9ec2d4f7fe38
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/yaml-schema-cpp"
    PACKAGE_NAME yaml-schema-cpp
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
