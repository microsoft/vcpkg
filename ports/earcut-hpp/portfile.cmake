vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/earcut.hpp
    REF "v${VERSION}"
    SHA512 15f5ea72bddf63549bc7a178009ccc949bf078f45f527bd9d41d4e40b5972e09f5c61dd25375bf12dd7a623f9ad0df556733aa1492153c214715ad4319cb21ed
    HEAD_REF master
    PATCHES
        disable-tools.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEARCUT_BUILD_TESTS=OFF
        -DEARCUT_BUILD_BENCH=OFF
        -DEARCUT_BUILD_VIZ=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME earcut_hpp
    CONFIG_PATH share/cmake/earcut_hpp
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
