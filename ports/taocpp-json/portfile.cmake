set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/json
    REF f357d7269b7503eed21d0c3b98b9075c28a98f56 # accessed on 2020-09-14
    SHA512 4a4be970779ed0c6044c7ad40918ad6b3908ca10dbfb3738cbebb62154d437ad13ca27947119a6b1a6c8d92b22a9282477c73ddc5721ca30b8b355b77d7ce729
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTAOCPP_JSON_BUILD_TESTS=OFF
        -DTAOCPP_JSON_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/taocpp-json/cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE.double-conversion"
        "${SOURCE_PATH}/LICENSE.itoa"
        "${SOURCE_PATH}/LICENSE.ryu"
)
