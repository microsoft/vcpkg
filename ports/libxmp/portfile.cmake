vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libxmp/libxmp
    REF 2c339d0f7517e464d3f2f743212ca76c8c6fe1f1
    SHA512 6c8eca7e37ad9b51b4d9aea08f253c6c4c34f01bfc44b2be4066450b8e34c4bc96a1d1129edc761de4d2e281f718f8d969ce86273af23e37ee172072af8b0a2c
    PATCHES
        fix-cmake-config-dir.patch
        fix-uwp-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        depackers  LIBXMP_DISABLE_DEPACKERS
        prowizard  LIBXMP_DISABLE_PROWIZARD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "libxmp"
    CONFIG_PATH "lib/cmake/libxmp"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/docs/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
