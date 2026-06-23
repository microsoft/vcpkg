vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/benchmarksuite
    REF "v${VERSION}"    
    SHA512 d63a9b42e6d917d6da5775009a632a9a4e79b5e01cdf267aa383e27096a59739f9004d7e8f15ae5e02b286ba07523732f5b86d4cc3b12ec06ba7ebb3b35febcc
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
