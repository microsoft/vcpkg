vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF "v${VERSION}"
    SHA512 8a6209421cc238831909073a8584ffbc91a59fc57f7e3e0da19ba4279a7de5d44522a30f6900b996f0480b0b44459d8e1e8264d3db8bee49cb46c5ee5740a217
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
