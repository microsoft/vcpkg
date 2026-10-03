vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF ${VERSION}
    SHA512 04c994a123ada8a876a654197d7b36cdee299c0f62a43c8110d096f6eec8cee6b2cf70d8eee3be79f70c7d76743785c1070b40ef281e11065cfbdcdb477a1b14
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
