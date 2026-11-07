vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/TinyEXIF
    REF ${VERSION}
    SHA512 55ad864d1b6af557eacf1c0e7d58fcdbfe3da4b5b6b9da7977c8717d53a4d6ab5f9e629aa4d336026745e14ff7b736a5fbf68a813c148636c0a20c191f26c5e4
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
