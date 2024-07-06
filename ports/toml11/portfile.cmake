vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF "v${VERSION}"
    SHA512 1d7d38c32af178e15b007f5c7a69f4789ba8b0c1ee1e2dc6b853fd38d5794944305baff86e97c9b49b28dbeadec6165273a7de16b94c06be9fc5a46d27cbec3e
    HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DCMAKE_CXX_STANDARD=11
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/toml11)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
