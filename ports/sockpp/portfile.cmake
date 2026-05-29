vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fpagliughi/sockpp
    REF "v${VERSION}"
    SHA512 99191c9551ff345f96af9177d124c6e10f3da8e87021576058b63df82ee64461cb8fc134919fe390617200aebf222e70501e3cee43fc0a294596947669ed4f03
    HEAD_REF master
    PATCHES
        android-strerror_r.diff
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "\${SOCKPP}-static" "\${SOCKPP}" IGNORE_UNCHANGED)

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
