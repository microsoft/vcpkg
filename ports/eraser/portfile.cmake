vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/eraser
    REF "v${VERSION}"
    SHA512 f0cc02d1bc643239ed648006db0c13e704e803537060930080b2cdd692fa09082a5d73dc7487a6c4e5aa95d0a7bf6fd4623ee8567ebd152c20221a9c8fa0f7eb
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
