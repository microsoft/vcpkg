vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngtcp2/ngtcp2
    REF "v${VERSION}"
    SHA512 0fa71544d70080ed9b0373383aaf985c7ed162913a480371affb3131cb3bb55e9a9653896da3801f5b1d121fc654232f5e463298f8070413f309bb4a514898f8
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED_LIB)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wolfssl  ENABLE_WOLFSSL
        gnutls   ENABLE_GNUTLS
        libressl ENABLE_OPENSSL
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
