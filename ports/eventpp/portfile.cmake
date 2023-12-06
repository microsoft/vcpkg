vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wqking/eventpp
    REF "v${VERSION}"
    SHA512 b39994e9bd581d6bb61b634c434c46075e41ec2217e1174578fefd206a927bd725744ae0724d319cde8f2b2a43d2e030a04c271197500d94c6b1afd849f779fd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/eventpp")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license")
