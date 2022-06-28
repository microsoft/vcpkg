vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF v1.9.0
    SHA512 955ea6aa184ad1c0cd3902e252cd7dc6c3b877311e037243223d2e07824146440c690828e77fc41ee943bd8738b8cd03a9b011c1dedacc52e9a7f63d40d242b4
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
