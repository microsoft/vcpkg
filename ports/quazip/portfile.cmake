vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stachenov/quazip
    REF v1.4
    SHA512 38ce3aa77df1fd92229454e56b7290c066d1e319afa36a9f8ec8477004ae94df682e8f454f13cdaf586a1d0b0e033fe698081033a19536ecd53dd1e4b0204af9
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QuaZip-Qt6-1.4 PACKAGE_NAME quazip-qt6)
vcpkg_copy_pdbs()
# Qt6 pkg-config files not installed https://github.com/microsoft/vcpkg/issues/25988
# vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)