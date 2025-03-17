vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "v${VERSION}"
    SHA512 588d939c3ba9758debffbe675580d2013c0e18ff8cbfdf2b4aaad28a5a013c579ca06206c2b0446b25203db48e59af8a16168e32f265e0939f046b18bf598803
    HEAD_REF main
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
