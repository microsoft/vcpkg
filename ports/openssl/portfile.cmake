if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
endif()

set(OPENSSL_VERSION 1.1.1k)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz"
    FILENAME "openssl-${OPENSSL_VERSION}.tar.gz"
    SHA512 73cd042d4056585e5a9dd7ab68e7c7310a3a4c783eafa07ab0b560e7462b924e4376436a6d38a155c687f6942a881cfc0c1b9394afcde1d8c46bf396e7d51121
)

vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
)

vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        NO_ADDITIONAL_PATHS
        DISABLE_VERBOSE_FLAGS
        DISABLE_STATIC_SHARED
        CONFIGURE_FILE config
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/ssl/certs")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/ssl/private")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/ssl/certs")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/ssl/private")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)