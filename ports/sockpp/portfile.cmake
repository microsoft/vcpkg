vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fpagliughi/sockpp
    REF "v${VERSION}"
    SHA512 e675bd9e094108c222128f65f64519d550f5dcc36ec217c57277d2d3bfadd4410d06278cfe2858e24d36fdcc0cced8d87d05c61abb94848d073182c29860b61a
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "\${SOCKPP}-static" "\${SOCKPP}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOCKPP_BUILD_SHARED=OFF
        -DSOCKPP_BUILD_STATIC=ON
        -DSOCKPP_BUILD_DOCUMENTATION=OFF
        -DSOCKPP_BUILD_EXAMPLES=OFF
        -DSOCKPP_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
