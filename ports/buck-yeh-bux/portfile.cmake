vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF "${VERSION}"
    SHA512 af29755bafe9bca0a58465a6c5a65aae1e9ce05d36522fbc97ad676d50ff2dd4584d65cfcdf76c292cad45ce58f487096fb2c6120f0c3a67ca1aeb6d2e13f1c1
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
