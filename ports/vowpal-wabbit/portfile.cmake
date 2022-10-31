vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VowpalWabbit/vowpal_wabbit
    REF 9496a6dd5610910a495ca004a93c8ab6913293e4
    SHA512 df4da3f3ab763dbd113b0ace0552d676ec905a6ff0d942d9fc1828e36fb8440d1b75a61c1ea6de09879e0f52547366936d02a77dba2bac89503a075da12414db
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
        -DVW_BUILD_VW_C_WRAPPER=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/VowpalWabbit)
vcpkg_fixup_pkgconfig()
