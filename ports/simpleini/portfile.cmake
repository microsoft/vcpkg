vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brofield/simpleini
    REF "v${VERSION}"
    SHA512 f2ba16c76f88d8e299429c401c6076417299c98b0976c25c4fc07ebe563828da93a533e1a2cc4b7078c090416fd02ee4b095313d43b1060dee398b1d31ac7517
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
