vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF "v${VERSION}_libuv_v1.44"
    SHA512 6794d71f88888e58d53fbea18eecb8e43a01f9965012a4b0f3c29bd5dd1280aac8dfe735d3df7f401d309e182fa7ed4e2e0b4aff49beaa1973dcd61153bbb1af
    PATCHES
        fix-find-libuv.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_UVW_LIBS=${BUILD_STATIC}
        -DFETCH_LIBUV=OFF
        -DFIND_LIBUV=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uvw)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
