vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ZXShady/enchantum
    REF ${VERSION}
    SHA512 f0eb25164bc6b9f0579267f03f2080615972b4a81ff2f9b0fa8c8621888b775e13e7c250895678e4a98bfccdbb38b5d3e137b3ac198cb6122f68ec015293d11b
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# upstream installs enchantumConfig.cmake into <prefix>/cmake but enchantumTargets.cmake
# into <prefix>/share/enchantum/cmake; merge them so the config's include() resolves
file(RENAME "${CURRENT_PACKAGES_DIR}/cmake/enchantumConfig.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake/enchantumConfig.cmake")
file(RENAME "${CURRENT_PACKAGES_DIR}/cmake/enchantumConfigVersion.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake/enchantumConfigVersion.cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake")

vcpkg_cmake_config_fixup(CONFIG_PATH "share/${PORT}/cmake")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
