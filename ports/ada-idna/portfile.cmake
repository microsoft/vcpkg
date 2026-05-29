vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/idna
    REF "${VERSION}"
    SHA512 2ac71b37b71a3335fe11fd24b3e734447ff939d9c3ec502580e089b6b604f64f0744da1d059f1ee205bbdbccaf0756df3bd4f345dbe95908f6e4c54ce09b234c
    HEAD_REF main
    PATCHES
        install.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simdutf         ADA_USE_SIMDUTF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DADA_IDNA_BENCHMARKS=OFF
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-ada-idna)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    COMMENT "ada-idna is dual licensed under Apache-2.0 and MIT"
    FILE_LIST
       "${SOURCE_PATH}/LICENSE-APACHE"
       "${SOURCE_PATH}/LICENSE-MIT"
)
