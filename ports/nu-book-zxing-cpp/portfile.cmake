vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zxing-cpp/zxing-cpp
    REF "v${VERSION}"
    SHA512 f1de8df783061a152a18cd9102ac0c579c40c76ab4a5ba9f30bcb8ddb532f3fac08736840a631adbf7c30a7fa00ce8d65625c8cd695288620601708e8f256a53
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
