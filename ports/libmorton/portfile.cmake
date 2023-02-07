vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Forceflow/libmorton
    REF "v${VERSION}"
    SHA512 ff1b0ebca3d38e886b4320bab38360dd537c3f63bf02aedfe5b00a81e026e52aff1a929361f8e2c4de9a18272a9e2a24c0085d7beb1be0adf6434777aad02ae5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/libmorton)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)