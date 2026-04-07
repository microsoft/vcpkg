vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pngwriter/pngwriter
    REF 0.7.0
    SHA512 3e4ef098e4d715d18844cada64f32dbf079fdd1f7a64b6fe5e19584094f6b2a61f80c53804f936b6eefd7ef9dad4a01a7210b1273939d385a0850e48f8ba6683
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PNGwriter)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/doc/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pngwriter" RENAME copyright)
