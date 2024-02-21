vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremy-rifkin/libassert
    REF "v${VERSION}"
    SHA512 beba94e033f7e43c84123736a32725a333c915392d5dc57c26a63f832a507564d79f290a151cb136de8bded3d8d343dad3c4bf2efec9977d878df3c9a8677554
    HEAD_REF main
    PATCHES
        runtime_destination.patch
        magic-enum.patch
        include-dir.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DASSERT_USE_EXTERNAL_CPPTRACE=ON
        -DASSERT_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME assert
    CONFIG_PATH lib/cmake/assert
)
vcpkg_copy_pdbs()

file(APPEND "${CURRENT_PACKAGES_DIR}/share/assert/assert-config.cmake" "include(CMakeFindDependencyMacro)
find_dependency(magic_enum)
find_dependency(cpptrace)")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/assert/third_party")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
