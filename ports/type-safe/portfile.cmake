vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/type_safe
    REF "v${VERSION}"
    SHA512 90e256af61649706c97d2cf317ce34b2b953fc841b04eab8193a865d3eced9a1044d22ecb520688f3adf35a06c346945604f177a933e7709cc167bb1637ccb4e
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME type_safe CONFIG_PATH lib/cmake/type_safe)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
