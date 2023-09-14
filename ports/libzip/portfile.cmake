vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF 5532f9baa0c44cc5435ad135686a4ea009075b9a #v1.9.2
    SHA512 1105bc48c8a554a7fce84028197427b02ff53508592889b37e81cc419eb208d91112b98df2bf2d6f5629887e4418230ee36e3bf03c9ae39cdc39cfa90e7e3e7f
    HEAD_REF master
    PATCHES
        fix-dependency.patch
        use-requires.patch
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
