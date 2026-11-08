set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO greg7mdp/gtl
    REF "v${VERSION}"
    SHA512 1682f6fd3b893f9985998269e6c32de4a7591ebd58aad8a08d0e6f3be8ce32f71b6bfaba5d5d6b49542094cf96255d894fcbd3decf828dec75b83b17cd80411f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTL_BUILD_TESTS=OFF
        -DGTL_BUILD_EXAMPLES=OFF
        -DGTL_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/gtl")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
