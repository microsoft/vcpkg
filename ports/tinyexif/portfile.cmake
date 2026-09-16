vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF ${VERSION}
    SHA512 8e2c0b4f1edcec0dbf4cb6164034520cc1ba23d4681af62dd558f759cb6a184c0f53ce24a41eb21f3f164b46429692f5267c175b4b8a8b15485764927329b047
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" LINK_CRT_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLINK_CRT_STATIC_LIBS=${LINK_CRT_STATIC}
        -DBUILD_DEMO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyEXIF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
# Upstream is MIT for its own contributions, but portions derive from easyexif
# and remain additionally subject to its BSD-2-Clause terms; both notices ship
# in the source tree and both must be installed.
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/LICENSE.easyexif"
)
