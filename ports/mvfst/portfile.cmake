vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 e032f433f460f4377f0ff2e30db605b7ea31f42df561adaea42db27040a652fcb851e99fd1c9b9f4095de6a2df12ccb51c8699c131256466bb5fc9eff90d1011
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
