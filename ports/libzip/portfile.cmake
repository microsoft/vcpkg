vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF 66e496489bdae81bfda8b0088172871d8fda0032 #v1.7.3
    SHA512 ae0cda3e9decf5a71bf1e0907a2a21b2c0d83e6e576faf4d9401d6954707ae298c1c09febbc5339f457ace3577fdd405a790c819ef24778990ca6bf1e9516d54
    HEAD_REF v1.7.3
    PATCHES 
        fix-findpackage.patch
        fix-dependency.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
 
# Remove include directories from lib
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
