vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zxing-cpp/zxing-cpp
    REF "v${VERSION}"
    SHA512 4e05755e1c509b1c9bc09d733af9131cb0198ff09b514ef2d6504a4ad4f9f3a9d8740f9b50ac0fcc044bb63f2e87bfde9ca4f9f67d3240a238cf99e50799056c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZXING_EXAMPLES=OFF
        -DZXING_WRITERS=OLD
        -DZXING_C_API=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
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
