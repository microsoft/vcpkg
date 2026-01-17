vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qpdf/qpdf
    REF v${VERSION}
    SHA512 eed4c063bcb9e0fddfe03d16c63902f2552aa987e9d8048a592e677e43caf035ed1231caf509d4b2e7391593d72f9493156129c522b4022d3633ed62784c2338
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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DREQUIRE_CRYPTO_NATIVE=ON
        -DUSE_IMPLICIT_CRYPTO=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qpdf)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE.md" "${SOURCE_PATH}/LICENSE.txt")
