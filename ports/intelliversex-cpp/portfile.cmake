vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Intelli-verse-X/Intelli-verse-X-Unity-SDK
    REF "v1.5.0"
    SHA512 0
    HEAD_REF main
)

set(IVX_SOURCE_PATH "${SOURCE_PATH}/SDKs/cpp")
vcpkg_cmake_configure(
    SOURCE_PATH "${IVX_SOURCE_PATH}"
    OPTIONS
        -DIVX_BUILD_TESTS=OFF
        -DIVX_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
