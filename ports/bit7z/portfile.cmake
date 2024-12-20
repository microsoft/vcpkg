vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rikyoz/bit7z
    REF "v${VERSION}"
    SHA512 02ee10a66598e9a2f5b47f35392dc8f3de11e01dac9d657e1321d1de97baf9832b1f1559054160d122dddd0427f54076820d7252185912c38b2f277d9c5fa1c0
    HEAD_REF master
    PATCHES
      fix_install.patch
      fix_dependency.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-bit7z-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        regex-matching                  BIT7Z_REGEX_MATCHING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBIT7Z_AUTO_FORMAT=ON
        -DBIT7Z_AUTO_PREFIX_LONG_PATHS=ON
        -DBIT7Z_DISABLE_ZIP_ASCII_PWD_CHECK=OFF
        -DBIT7Z_PATH_SANITIZATION=ON
        -DBIT7Z_DISABLE_USE_STD_FILESYSTEM=OFF
        -DBIT7Z_USE_STD_BYTE=OFF
        -DBIT7Z_USE_NATIVE_STRING=OFF
        -DBIT7Z_USE_SYSTEM_CODEPAGE=OFF
        -DBIT7Z_BUILD_TESTS=OFF
        -DBIT7Z_BUILD_DOCS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-bit7z CONFIG_PATH share/unofficial-bit7z)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
