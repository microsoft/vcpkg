vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jiixyj/epoll-shim
    REF v${VERSION}
    SHA512 03f2cf64854dcb7c065284bbe765e6b52a9504969a733b450746226334fb9852e210b3db0d8ae40733abf62d75d35cc539140e9b5fb3507de9e47ebbc15f2ae3
    HEAD_REF master
    PATCHES
        000-install-pkg-config-into-standard-location.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/epoll-shim)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
