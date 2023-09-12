vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "RELEASE_${VERSION}"
    SHA512 bd7db0fcf25ebf492b4d8f7da8fdb6cc79400d7d0fa5856ddae259cb24817034fc97d4828cbde42434f41198dcfb6732ac63c756abd962689f4249ca64bf19c6
    HEAD_REF master
    PATCHES
        dependencies.diff
        fix-zlib-ver-required.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/minizip")

set(USE_WINDOWSSTORE OFF)
if (VCPKG_TARGET_IS_UWP)
    set(USE_WINDOWSSTORE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DUSE_SYSTEM_MINIZIP=1
        -DWINDOWSSTORE=${USE_WINDOWSSTORE}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
