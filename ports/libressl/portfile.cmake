if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
    message(FATAL_ERROR "Can't build libressl if openssl is installed. Please remove openssl, and try install libressl again if you need it.")
endif()

vcpkg_download_distfile(
    LIBRESSL_SOURCE_ARCHIVE
    URLS "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/${PORT}-${VERSION}.tar.gz"
         "https://github.com/libressl/portable/releases/download/v${VERSION}/${PORT}-${VERSION}.tar.gz"
    FILENAME "${PORT}-${VERSION}.tar.gz"
    SHA512 e18aa7016048aaec5988cedc3daea2f3f9c114760c0b7e15b18388ed3ab0a1a0386860a318a8cdbe961bb4369db28a9fe01a9bf04f97b7fbafd45815693fd634
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBRESSL_SOURCE_ARCHIVE}"
    PATCHES
        pkgconfig.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools" LIBRESSL_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBRESSL_INSTALL_CMAKEDIR=share/${PORT}
        -DLIBRESSL_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBRESSL_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

# libressl as openssl replacement
configure_file("${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/openssl/vcpkg-cmake-wrapper.cmake" @ONLY)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ocspcheck openssl DESTINATION "${CURRENT_PACKAGES_DIR}/tools/openssl" AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/etc/ssl/certs"
    "${CURRENT_PACKAGES_DIR}/debug/etc/ssl/certs"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man"
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/COPYING"
    COMMENT [[
LibreSSL code: BSD-2-Clause AND BSD-3-Clause AND ISC AND MIT AND OpenSSL.
Upstream's files do not declare a license for the installed CA bundle, so the package license is null.
Consumers supplying their own CA bundle can use the code expression above for LibreSSL
and account for their bundle's license separately.
]]
)
