vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF "v${VERSION}"
    SHA512 b364500f76e2ecb0fe21b032d831272e3f1dfeea71af74e325f8fc4ce9dcdb3c941b97a5b422bdeafb9facd058597b90f8bfc284fb9afe3c33fefa15dd5a010b
    HEAD_REF master
    PATCHES
        fix-find-brotli.patch
        fix-system-version.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        brotli  HTTPLIB_REQUIRE_BROTLI
        openssl HTTPLIB_REQUIRE_OPENSSL
        zlib    HTTPLIB_REQUIRE_ZLIB
        zstd    HTTPLIB_REQUIRE_ZSTD
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DHTTPLIB_USE_OPENSSL_IF_AVAILABLE=OFF
    -DHTTPLIB_USE_ZLIB_IF_AVAILABLE=OFF
    -DHTTPLIB_USE_BROTLI_IF_AVAILABLE=OFF
    -DHTTPLIB_USE_ZSTD_IF_AVAILABLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME httplib CONFIG_PATH lib/cmake/httplib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
