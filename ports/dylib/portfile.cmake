vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martin-olivier/dylib
    REF "v${VERSION}"
    SHA512 8e691c1bc73f381ce8ec50d85165c122ba55167b050e696c8b26ccf1ba14999ca8129fb6c5b6c3320166f606acb2c21867d0786347c341d1267815580beb5c0a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/dylib)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
