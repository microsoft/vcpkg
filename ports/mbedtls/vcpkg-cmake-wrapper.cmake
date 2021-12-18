include(FindPackageHandleStandardArgs)

find_path(MBEDTLS_INCLUDE_DIR mbedtls/ssl.h)

find_library(MBEDTLS_CRYPTO_LIBRARY mbedcrypto)
find_package(pthreads_windows QUIET)
set(MBEDTLS_CRYPTO_LIBRARY ${MBEDTLS_CRYPTO_LIBRARY} ${PThreads4W_LIBRARY})
find_library(MBEDTLS_X509_LIBRARY mbedx509)
find_library(MBEDTLS_TLS_LIBRARY mbedtls)
set(MBEDTLS_LIBRARIES ${MBEDTLS_CRYPTO_LIBRARY} ${MBEDTLS_X509_LIBRARY} ${MBEDTLS_TLS_LIBRARY})

if (MBEDTLS_INCLUDE_DIR AND EXISTS "${MBEDTLS_INCLUDE_DIR}/mbedtls/version.h")
    file(
        STRINGS ${MBEDTLS_INCLUDE_DIR}/mbedtls/version.h _MBEDTLS_VERLINE
        REGEX "^#define[ \t]+MBEDTLS_VERSION_STRING[\t ].*"
    )
    string(REGEX REPLACE ".*MBEDTLS_VERSION_STRING[\t ]+\"(.*)\"" "\\1" MBEDTLS_VERSION ${_MBEDTLS_VERLINE})
endif()

find_package_handle_standard_args(
    mbedTLS
    REQUIRED_VARS
        MBEDTLS_INCLUDE_DIR
        MBEDTLS_CRYPTO_LIBRARY
        MBEDTLS_X509_LIBRARY
        MBEDTLS_TLS_LIBRARY
        PThreads4W_FOUND
    VERSION_VAR MBEDTLS_VERSION
)
