set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imakris/sintra
    REF "v${VERSION}"
    SHA512 6cc28c4281566b3c9b0d1364d6f930f9fe13dcd7018262bedceb77cc212d4e1459b0b2920a75d854faefa12fddef0ee23b01942e4eb4d4015d60e1ba9f9f00f5
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSINTRA_INSTALL=ON
        -DSINTRA_BUILD_EXAMPLES=OFF
        -DSINTRA_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sintra")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
