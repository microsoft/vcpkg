# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hpc-maths/samurai
    REF "v${VERSION}"
    SHA512 38750a3849023eeebaf356e399ff69f96eac8d696e366953ca5b689c038508b7e8dfea2bdb49c7f44ab909dcf94950160eabd3e6cbb55957c55461c008f17094
    HEAD_REF master
    PATCHES
        0001-add-hdf5-dependency-in-cmake.patch
)

set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_get_vars(cmake_vars_file)
include(${cmake_vars_file})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFETCHCONTENT_FULLY_DISCONNECTED=OFF
        -DENABLE_VCPKG=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
