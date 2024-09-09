vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 7f86c6634a599fafaba012d30c586340074cbed9d9ac6eadc270da253b725ce9ae9f920d1bf1e60530579b6e4fb4cd5c0eda8c491c0c704da471e4ac05c29c7b
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
