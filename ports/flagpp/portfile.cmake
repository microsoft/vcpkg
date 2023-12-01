vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/flagpp
    REF "v${VERSION}"
    SHA512 c0a9c63846075677b89af38aecd0536df430d7a2600115067644af58aefb6941f56a0e5bd13a4006b032cd96804cc0acde9be2725ddd79691c878f7e5ed04b92
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
