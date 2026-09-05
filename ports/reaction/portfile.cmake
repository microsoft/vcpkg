vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lumia431/reaction
    REF "${VERSION}"
    SHA512 7747b621c790318d3240f8634bf2310420c93b1418f9ac1384d784ab08658f12d2631e59d5927dc2b81c7801d150a785ea1cdfbb0b7025ea0531047023f8dab1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/reaction)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

