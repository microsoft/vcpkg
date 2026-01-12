vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/zoe
    HEAD_REF master
    REF "v${VERSION}"
    SHA512 af895f772b465b34eb938b712bfd9b00bb170d23125e05161843293c13329bfc1147bd22ce990b189580d0946b94e725b99cefaafd3aeca758de5c6a55bc33a9
    PATCHES
        cmake.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        openssl     VCPKG_LOCK_FIND_PACKAGE_OpenSSL
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZOE_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZOE_BUILD_SHARED_LIBS:BOOL=${ZOE_BUILD_SHARED_LIBS}
        -DZOE_BUILD_TESTS:BOOL=OFF
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
