if(EXISTS "${CURRENT_INSTALLED_DIR}/include/openssl/ssl.h")
    message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
endif()

set(OPENSSL_VERSION 1.1.1j)
vcpkg_download_distfile(ARCHIVE
        URLS "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" "https://www.openssl.org/source/old/1.1.1/openssl-${OPENSSL_VERSION}.tar.gz"
        FILENAME "openssl-${OPENSSL_VERSION}.tar.gz"
        SHA512 51e44995663b5258b0018bdc1e2b0e7e8e0cce111138ca1f80514456af920fce4e409a411ce117c0f3eb9190ac3e47c53a43f39b06acd35b7494e2bec4a607d5
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