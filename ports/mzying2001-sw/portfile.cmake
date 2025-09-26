vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mzying2001/sw
    REF ${VERSION}
    SHA512 82206b05ce8ac6801ed4d562188b696a0588b3ea0ae5ee49111cbfdeec1bf39ffcc490cd96a230a851e9665414a684359aed9d8b4d5f2626167ddbd98a8b0547
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sw
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME sw
    CONFIG_PATH share/mzying2001-sw
)

vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
