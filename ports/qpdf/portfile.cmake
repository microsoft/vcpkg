vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qpdf/qpdf
    REF v${VERSION}
    SHA512 22395160ff16556fe3544790dff1ade63489cfc494c46ae84e7db4b41e0592b7b6ee4d80e4d3862491f09db91ab13868abcfc22b7918a74fe2966669d619469b
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gnutls         REQUIRE_CRYPTO_GNUTLS
        native-crypto  REQUIRE_CRYPTO_NATIVE
        openssl        REQUIRE_CRYPTO_OPENSSL
        zopfli         ZOPFLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    GENERATOR Ninja
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_IMPLICIT_CRYPTO=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

# Don't want qpdf program, but no build option to exclude it. Use Ninja generator subdirectory install targets.
vcpkg_cmake_build(TARGET libqpdf/install)
vcpkg_cmake_build(TARGET include/install)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qpdf)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE.md" "${SOURCE_PATH}/LICENSE.txt")
