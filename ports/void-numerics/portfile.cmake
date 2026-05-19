set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nihilai-collective/void-numerics
    REF "v${VERSION}"
    SHA512 3a3cc255271bfd9ba4e8819d2290f8a2482d71316b960b548fde7b51e36dff41d9fcfc7b1e9997f327377c8232e92c24e2ad828dd337b85ec833c2450ed19958
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
