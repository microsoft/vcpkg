# Header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SSARCandy/cofetch
    REF "v${VERSION}"
    SHA512 f6249895461d8db7b2f3d7801944fadaeab85fe648bbc01840f523dafd23c4fe267a2669540a892c4a3af1d50296d0d4f48b497a8de019fd11adbe2e6ea4e495
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOFETCH_INSTALL=ON
        -DCOFETCH_BUILD_EXAMPLES=OFF
        -DCOFETCH_USE_VENDORED_ASIO=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cofetch)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
