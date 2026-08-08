vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/jsonifier
    REF "v${VERSION}"
    SHA512 146d55c941807f5f15ae9f4782538a13c5f730bfabb6a4dd8ced9a02ba3fb78ad0d9e795579c343cba72ece2d2b94d9781b3ef6d45431c2c87370c368e965c41
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
