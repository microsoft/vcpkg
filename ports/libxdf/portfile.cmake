vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xdf-modules/libxdf
    REF 524c37ff7aa4130ccb779ed035165bf43312bd90
    SHA512 8c5eb1b37b9b1e6f38dcd9cc3b930a3a4af03e7fb3a67209a3b53e9c3259f41f5f0fa56d301b98c105ae75943b4ab6ee0b432965f0d4e99278829792b2ab1474
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXDF_NO_SYSTEM_PUGIXML=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
