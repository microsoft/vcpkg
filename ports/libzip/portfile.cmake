vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF dcd9a0bfe1ac2893d7f62bafb19f0a4d7b08c0f7 #v1.7.1
    SHA512 33ad594398f79544636464d6ae0892553a212dc833b508820f81f10823c3a5c4016288d05953176fb8d52919414edd28f26da6037b93129a58826abdcb501d18
    HEAD_REF master
    PATCHES fix-findpackage.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/libzip)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
 
# Remove include directories from lib
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
