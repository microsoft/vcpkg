vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ToruNiina/toml11
    REF "v${VERSION}"
    SHA512 1779c6b21a0a4000f49e5bf3a8b1288989622eb4a4e365cd6c49d9a8cc859ad18514b94dca63bd8a49f554aa7387882a1a089fadde267cebdf2a8aa49aacd11b
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
