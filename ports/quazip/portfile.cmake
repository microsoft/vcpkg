vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stachenov/quazip
    REF v1.5
    SHA512 c88850f1672d20c375798c58d1cb77744ca63e93b379cf3035a528b57e83a52c1908023870152ce5fc49ad0ccf93d723dbc730b8c1d2abe18cf0b13fba3be1e1
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2 QUAZIP_BZIP2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DQUAZIP_QT_MAJOR_VERSION=6
        -DQUAZIP_FETCH_LIBS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QuaZip-Qt6-1.5 PACKAGE_NAME quazip-qt6)
vcpkg_copy_pdbs()
# Qt6 pkg-config files not installed https://github.com/microsoft/vcpkg/issues/25988
# vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)