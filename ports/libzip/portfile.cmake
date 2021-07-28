vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF 26ba5523db09213f532821875542dba7afa04b65 #v1.8.0
    SHA512 caa4610e10a45260d8f06e4e728b231f0fcfacd90d3091a096b273997b7505857a78a8013d0571c3b25543d894eb049d1e7f5385e910066e464b3d208390570f
    HEAD_REF master
    PATCHES 
        fix-findpackage.patch
        fix-dependency.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
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
