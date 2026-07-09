vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF "v${VERSION}"
    SHA512 5c8a151d0d40dd413975e12e4bbfd790a087c7e9c96bf86db31ce43921cbccece01a5cca78e47a8cfd12370f97e174a158aa8a826781e12fa256b157665e1310
    HEAD_REF master
    PATCHES
        fix-find-brotli.patch
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
