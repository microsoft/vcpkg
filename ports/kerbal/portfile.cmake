vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO WentsingNee/Kerbal
        REF "v${VERSION}"
        SHA512 a99d34e2112f58d4acb47bc8fe6260d74e51aafc2c90960186cb6d0a867604b655968a0600336d29af624ddb186f56959001c29a5870c2c08bfb27d4ba331f4f
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
        CONFIG_PATH "share/cmake/Kerbal"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
