vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF rel-1-6-1
    SHA512 7ee414c063f9f76bec7d96ff9dadbc4be8d37a7b907b977882bf40f8ab66f0e46d3b8f70083c7bd272cc298d855d0d72b494b5772f26e1f4ff7ffeefe780adaf
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bzip2 ENABLE_BZIP2
    liblzma ENABLE_LZMA
    openssl ENABLE_OPENSSL
    wincrypto ENABLE_WINDOWS_CRYPTO
    commoncrypto ENABLE_COMMONCRYPTO
    mbedtls ENABLE_MBEDTLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_DOC=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_REGRESS=OFF
        -DBUILD_TOOLS=OFF
        -DENABLE_GNUTLS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Remove include directories from lib
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
