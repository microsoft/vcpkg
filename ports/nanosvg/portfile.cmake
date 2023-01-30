vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/nanosvg
    REF 9da543e8329fdd81b64eb48742d8ccb09377aed1
    SHA512 c1f559bbf3bc5fa7606b653ec702f62589a321132e515695cfcd1a8ed50495a7ec1ff621a60788a3930cd5e16041b540c9b9481f9c476905757cbbf735edf8c8
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME NanoSVG CONFIG_PATH lib/cmake/NanoSVG)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
