if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
  message(WARNING "Can't build libressl if openssl is installed. Please remove openssl, and try install libressl again if you need it. Build will continue since libressl is a subset of openssl")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
  return()
endif()

vcpkg_download_distfile(
    LIBRESSL_SOURCE_ARCHIVE
    URLS "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/${PORT}-${VERSION}.tar.gz"
         "https://ftp.fau.de/openbsd/LibreSSL/${PORT}-${VERSION}.tar.gz"
    FILENAME "${PORT}-${VERSION}.tar.gz"
    SHA512 b7b9f47c77fd27787b7c7ae7e78cd831fe9f7f32e280f54952994569bfe69ff03022e349aea9ea734c50b079693c6e15a3c1115ef0093e523437904074da5784
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${LIBRESSL_SOURCE_ARCHIVE}"
    PATCHES
        0002-suppress-msvc-warnings.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools" LIBRESSL_APPS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBRESSL_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBRESSL_APPS=OFF
)

vcpkg_cmake_install()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ocspcheck openssl DESTINATION "${CURRENT_PACKAGES_DIR}/tools/openssl" AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/etc/ssl/certs"
    "${CURRENT_PACKAGES_DIR}/debug/etc/ssl/certs"
    "${CURRENT_PACKAGES_DIR}/share/man"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/LibreSSL")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
