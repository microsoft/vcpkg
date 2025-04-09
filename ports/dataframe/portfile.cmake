vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hosseinmoein/DataFrame
    REF "${VERSION}"
    SHA512 1649ddf7ba113103d7fb2886f94f0d2fd6727cb2657749d1b4a4c18f0617f9714255a135bffd096e8391d7d7393d622f6736922886a48658dfdca30e53166df2
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHMDF_TESTING:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/DataFrame)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License")
