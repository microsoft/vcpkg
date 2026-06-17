vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brofield/simpleini
    REF "v${VERSION}"
    SHA512 a62c5748efe2473aae5bddab96ba9114d981a72f5b0d1a44d563daa085d5c231ed8c447794691d9bd67e1e0c6bfb44e4a8736be75fee59967d0c67ce3a59bb6e
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
