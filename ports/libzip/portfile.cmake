vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF "v${VERSION}"
    SHA512 cf7795ba52685bfc90cf4a3f993d29d6e27eabaca486098e04971fca31ab90a887194e6a77a5a9e19ade1a1d0855400c8108aa79724618f4204b1ba8d5e42c9d
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
