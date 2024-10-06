vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/ngtcp2
    REF "v${VERSION}"
    SHA512 b7bcb5e57a473142511d4edd7f6318eaa3e12a8db98b018ec8feb97382bd5ab3b634f258df082742d9c82b17d73ec2c388a62a9f848234e6e9609c7222671e07
    HEAD_REF main
    PATCHES
        openssl_required.patch
        boringssl.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIB)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wolfssl     ENABLE_WOLFSSL
        gnutls      ENABLE_GNUTLS
        libressl    ENABLE_OPENSSL
        boringssl   ENABLE_BORINGSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DENABLE_STATIC_LIB=${ENABLE_STATIC_LIB}"
        "-DENABLE_SHARED_LIB=${ENABLE_SHARED_LIB}"
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Libev=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Libnghttp3=ON
        -DCMAKE_INSTALL_DOCDIR=share/ngtcp2
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ngtcp2")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
