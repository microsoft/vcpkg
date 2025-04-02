vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cursey/safetyhook
    REF "v${VERSION}"
    SHA512 864980ee2464873890267467b6455f63615af51444669aa3b456a68464875eb2080af006d513137c0b1a9f63e0237ebbac8d870e9efa55db166909401a2fc062
    HEAD_REF main
)

vcpkg_find_acquire_program(GIT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DGIT_EXECUTABLE=${GIT}"
        "-DSAFETYHOOK_FETCH_ZYDIS=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/safetyhook)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
