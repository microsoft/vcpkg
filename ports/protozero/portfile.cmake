
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/protozero
    SHA512 90bf1f487efa0ad9da2f3b887b7a6dbd849fa3687dd2126c324f902a8584722f4f7d4a2ea86f6a0e75999f7be829f6ae26cad9df1cae55d0b29a9ec24a4dbfd2
    REF v1.7.1
    HEAD_REF master
    PATCHES
        fix-no-tests.patch  # from https://github.com/mapbox/protozero/pull/110
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
