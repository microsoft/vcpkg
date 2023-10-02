vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/llhttp
    REF refs/tags/release/v${VERSION}
    SHA512 d3e2c45f631e8bbc5b4b72f931a1af3e7b4f9d2851856a3c797577a3c261c7da15606efe41ff6b4f26713274f44eb3086019711461cb6bbe04e561b20af40a6f
    PATCHES
        fix-usage.patch
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LLHTTP_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LLHTTP_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_SHARED_LIBS=${LLHTTP_BUILD_SHARED}
        -DBUILD_STATIC_LIBS=${LLHTTP_BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "/lib/cmake/${PORT}"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT")

vcpkg_fixup_pkgconfig()
