vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF "v${VERSION}"
    SHA512 2ceed4f5783a88f9bfb6d044cbf3d1d5dd2b061d4cbe89e9c4e8773b85d37005562365e5e61e68a345867d1c2b3ab9c5ecdc98356b3cdb944b94201ed5edd00b
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
