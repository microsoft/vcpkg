set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO timsort/cpp-TimSort
    REF "v${VERSION}"
    SHA512 4110017fa25055724a896367f572f1119f0635c7be787f600d68714e4438dd73d0d023f3d021c3c15a3b09a47b13c43a927a2674e5ca601ef5a202b9bc56b849
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/gfx PACKAGE_NAME gfx-timsort)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
