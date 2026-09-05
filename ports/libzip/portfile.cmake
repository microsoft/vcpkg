vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF "v${VERSION}"
    SHA512 940a6e1145d6e0f2bd40577b4fa13f9c8e2115b267fb632dfb2443998a67d3e5de9a2026df5380c9b1b2fb181967d2f4dfd0929a9970d8bb196079a153a17bcc
    HEAD_REF master
    PATCHES
        config-vars.diff  # https://github.com/nih-at/libzip/pull/497
        dependencies.diff
        use-requires.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/Findzstd.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMbedTLS.cmake")

# By default options, find_package is called and capabilities are subject to the result.
# However, AES support backends are alternatives, and tried in order. The port shouldn't
# offer dependendencies, but now they are here. Let opt-in features override defaults.
if("mbedtls" IN_LIST FEATURES)
    message(STATUS "Selecting the mbedtls AES backend.")
    list(REMOVE_ITEM FEATURES default-aes openssl)
elseif("openssl" IN_LIST FEATURES)
    message(STATUS "Selecting the openssl AES backend.")
    list(REMOVE_ITEM FEATURES default-aes)
elseif("default-aes" IN_LIST FEATURES)
    message(STATUS "Selecting the system AES backend.")
endif()
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        # compression
        bzip2           VCPKG_LOCK_FIND_PACKAGE_BZip2
        liblzma         VCPKG_LOCK_FIND_PACKAGE_LibLZMA
        zstd            VCPKG_LOCK_FIND_PACKAGE_zstd
        # AES
        default-aes     ENABLE_COMMONCRYPTO
        default-aes     ENABLE_WINDOWS_CRYPTO
        openssl         ENABLE_OPENSSL
        openssl         VCPKG_LOCK_FIND_PACKAGE_OpenSSL
        mbedtls         ENABLE_MBEDTLS
        mbedtls         VCPKG_LOCK_FIND_PACKAGE_MbedTLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_DOC=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_REGRESS=OFF
        -DBUILD_TOOLS=OFF
        -DENABLE_GNUTLS=OFF
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_MbedTLS
        VCPKG_LOCK_FIND_PACKAGE_OpenSSL
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libzip")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
