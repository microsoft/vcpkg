vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hanickadot/compile-time-regular-expressions
    REF "v${VERSION}"
    SHA512 1ffb56ca88db5c8b0e5a5e1bf25f4eb9d59b43a31f9a38970bb2beaa22390e86a5beaf350b20e336759d7af99509c4c120b4638969719b931e316e01976c24dc
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCTRE_BUILD_TESTS=OFF
        -DCTRE_BUILD_PACKAGE=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/ctre")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
