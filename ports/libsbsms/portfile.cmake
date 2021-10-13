vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO claytonotey/libsbsms
    REF 2.3.0
    SHA512 e5b544c2bdbaa2169236987c7a043838c8d1761b25280c476d7a32656d482c6485cb33f579ea9d1ce586ec7b2913ed8fdcf1abe5c7cc8b9e4eef9ce87de54627
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sbsms" PACKAGE_NAME sbsms)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
