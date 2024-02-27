# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/header_libraries
    REF "v${VERSION}"
    SHA512 41ad00ac774906c8e3098374d2dc678fdc2df733f902821ce40ae8eb5b1418806442a32d163706ba080368309428f93d88b09628a32ec13776836ff795bb41f3
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
