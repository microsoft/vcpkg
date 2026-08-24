vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emoon/minifb
    REF "v${VERSION}"
    SHA512 fc4e3cfbe8dc3b105c06c771f394013ee3aede2adde8b81131b9b449021aab0dcde843faac0f99b5f5cb7496cbcbf3d84b2c7b8783e73a24b908ce4c68af0413
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMINIFB_BUILD_EXAMPLES=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
