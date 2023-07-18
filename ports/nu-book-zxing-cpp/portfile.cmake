vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zxing-cpp/zxing-cpp
    REF "v${VERSION}"
    SHA512 a00778c1fb7bb664176f7035aa96db4bab3e7ca28b5be2862182cb591d18edd4c3dfcbd34b4af08e0797bb4af893299d523f98aa84d266b68e4c766410e2e26d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BLACKBOX_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ZXing
    PACKAGE_NAME ZXing
)

file(READ "${CURRENT_PACKAGES_DIR}/share/ZXing/ZXingConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/ZXing/ZXingConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
${_contents}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
