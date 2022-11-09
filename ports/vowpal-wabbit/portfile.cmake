vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VowpalWabbit/vowpal_wabbit
    REF 16e9114f41343eed0a5f3f9881b171ce4ea6774a
    SHA512 7958480e5c62dc83a4e7b963bcd6d75ccb627fa96d1b8bdb5d30e8db94a851a100531bd8c9fd0ee4c668fcea1ccc7f195a258e0545e1864fdafba20d1d9ddcd2
    HEAD_REF master
    PATCHES cmake_remove_bin_targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVW_INSTALL=ON
        -DRAPIDJSON_SYS_DEP=ON
        -DFMT_SYS_DEP=ON
        -DSPDLOG_SYS_DEP=ON
        -DVW_BOOST_MATH_SYS_DEP=ON
        -DVW_ZLIB_SYS_DEP=ON
        -DVW_EIGEN_SYS_DEP=ON
        -DVW_BUILD_VW_C_WRAPPER=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/VowpalWabbit)
vcpkg_fixup_pkgconfig()
