vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rafat/wavelib
    REF 7f61bf592f3c470b2a7d8199431fde821d7253ac
    SHA512 c977e0a3fb9235d2ca84e25f0f5479c4bd6d8dc5d3f7fcb0d6c259519d2273f5eff6ab43d47d2b2e325a1f736135efbf69d2dced8ec2bc16a7f51d38ed4046eb
    HEAD_REF master
    PATCHES
        disable-test.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_UT=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
