vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chfast/intx
    REF "v${VERSION}"
    SHA512 8d3ab7f8492bc409f075118ed2a85b2efffe1ab9eaf36d93c5532f30d5e80b6eadbd3d5f5dd1e8dc5760f45b0236c633afdc492ad125ffdf9dcdea1ba9c382d9
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DINTX_INSTALL=ON
    -DINTX_TESTING=OFF
    -DINTX_BENCHMARKING=OFF
    -DINtX_FUZZING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME intx CONFIG_PATH lib/cmake/intx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
