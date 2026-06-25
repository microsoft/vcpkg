vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libxmp/libxmp
    REF libxmp-${VERSION}
    SHA512 ab7ed467a5fc968769ca8debbc648c1b86fcbfc95c5f9813cf6a47b35bc731009c1cbf09ecf4878f66c0903e70e68bc99eece37ee5da1a787d9c4fb711e9f790
    PATCHES
        fix-cmake-config-dir.patch
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
        -DLIBXMP_DOCS=OFF
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/COPYING")
