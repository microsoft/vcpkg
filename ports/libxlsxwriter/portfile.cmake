vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "v${VERSION}"
    SHA512 cca431b04eb51444f4dd8f096d50061726277a72e9ec216f9ac88b89dca1b227949ce3aa652bb2e81d1244b04ecdef791b0abde1dcc5b206aa36079a962aaab3
    HEAD_REF main
    PATCHES
        dependencies.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/minizip")

set(USE_WINDOWSSTORE OFF)
if (VCPKG_TARGET_IS_UWP)
    set(USE_WINDOWSSTORE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON
        -DUSE_SYSTEM_MINIZIP=1
        -DWINDOWSSTORE=${USE_WINDOWSSTORE}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
