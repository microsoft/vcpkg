vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rikyoz/bit7z
    REF "v${VERSION}"
    SHA512 d240997e3b1f6eb8d0b19c89bf3b12044cbb10ba495b4ba535efc1cd04390157031a303025819b6fd9a6a51bdca7b59ad50df45055cbde9130ffd4c8279a0863
    HEAD_REF master
    PATCHES fix_dependencies.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        regex-matching                  BIT7Z_REGEX_MATCHING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBIT7Z_USE_SYSTEM_DEPENDENCIES=ON
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
        -DBIT7Z_WARNINGS_AS_ERRORS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME bit7z CONFIG_PATH lib/cmake/bit7z)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
