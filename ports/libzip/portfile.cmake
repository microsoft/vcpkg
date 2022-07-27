vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF v1.9.2
    SHA512 a82cc4adb0ad0823a5baf61eb88751cdf111f1e2f6c5df9ec6f6b882624d7cfe5f4694435877eeab44f18abcf0d057f1e8c60a97c5327cc90ae3608ed84ecc7e
    HEAD_REF master
    PATCHES
        fix-dependency.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bzip2 ENABLE_BZIP2
        liblzma ENABLE_LZMA
        zstd ENABLE_ZSTD
        openssl ENABLE_OPENSSL
        wincrypto ENABLE_WINDOWS_CRYPTO
        commoncrypto ENABLE_COMMONCRYPTO
        mbedtls ENABLE_MBEDTLS
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
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libzip)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
 
# Remove include directories from lib
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/libzip" "${CURRENT_PACKAGES_DIR}/debug/lib/libzip")

# Remove debug include
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Copy copright information
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
