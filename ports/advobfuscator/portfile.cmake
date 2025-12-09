vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrivet/ADVobfuscator
    REF "v${VERSION}"
    SHA512 904d42c034e95770c3d2c6bff9ca80f92fdcf097f00a32a60f236e022342e60977395bb27791a24794d1e9f2c3cabf183b0faf5a1545799aa412f00a9868b715
    HEAD_REF main
    PATCHES
        cmake_export.patch # https://github.com/andrivet/ADVobfuscator/pull/43
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
