vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 da9a67e6987970462c22ac2174231c4c2d5531bd0ebd329cdaf8147f8777e03fb9a7c9ac2b23297dbe51fdf894720ac101ca11277f8a610a089fe9d06d0dbd38
    HEAD_REF main
    PATCHES
        uninstall-head.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
