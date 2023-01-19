vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/llhttp
    REF refs/tags/release/v8.1.0
    SHA512 3b79555f734a6a200a790f04f10be6d3ce5bd999c027a43c0900bb408e7d64be38fe4bbe9f15e57e389f07ba26b8089fc6ba5eef3b497742484f0719e92e9722
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
