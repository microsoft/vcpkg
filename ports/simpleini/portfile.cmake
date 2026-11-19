vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brofield/simpleini
    REF "v${VERSION}"
    SHA512 17b0a6f480cd669b79bb4fa19cbfc3b812aeda47773c1f6b008822b326b4cc475ce80066a75f06483801953179299125638270157806c758046974502b7174f5
    HEAD_REF master
    PATCHES
        disable-tests.patch
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SimpleIni PACKAGE_NAME SimpleIni)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENCE.txt")
