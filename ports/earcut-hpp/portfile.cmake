vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mapbox/earcut.hpp
    REF "v${VERSION}"
    SHA512 6628d1bdc20c8c19b4ee50ddf1e7eb7c055e4f1925006cf691043b4fb74f5574c4c648e51d68034f606ad2432cd3bb67f5a956bb34ed472b7408d9839dab3e94
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
