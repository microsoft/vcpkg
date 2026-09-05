vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/qpOASES
    REF 35b762ba3fee2e009d9e99650c68514da05585c5
    SHA512 691b91113cc8c0ab05f3143749c225a44bcb16a2dc6e60ecd3a4d00f44b8284a3d57dad83e4ef53d56b033e9ce9346735496263fb9f8def6f62ccd429f154a0d
    HEAD_REF master
    PATCHES
        export_target.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQPOASES_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/qpOASES)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
