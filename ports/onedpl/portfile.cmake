vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneDPL
    REF oneDPL-2021.7.0-release
    SHA512 57ba30dd8f200ed43fc4cc6f1dd4228305a36729ad4fcade261e1f90a27597a34c509ffd766495c28d38da9057307ef718f2743ce20c608f29c6d076b7405a97
    HEAD_REF master
    PATCHES
      cmake-config-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${DPLL_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME onedpl CONFIG_PATH lib/cmake/oneDPL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Copyright and license
file(INSTALL "${SOURCE_PATH}/licensing/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
