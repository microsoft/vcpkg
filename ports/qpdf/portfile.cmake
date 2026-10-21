vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qpdf/qpdf
    REF "v${VERSION}"
    SHA512 0d33cdfe7f537d8bc8201e2f2b5c1c4c3da81d8b92e3e25e6ba7642c6362e6b24aa14f4156a2723f571a65cd912fe3acf20c384337ae19876e1f2b38b6a39bb8
    PATCHES
        cmake-library-only.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gnutls         REQUIRE_CRYPTO_GNUTLS
        openssl        REQUIRE_CRYPTO_OPENSSL
        zopfli         ZOPFLI
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DREQUIRE_CRYPTO_NATIVE=ON
        -DUSE_IMPLICIT_CRYPTO=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qpdf)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE.md" "${SOURCE_PATH}/LICENSE.txt")
