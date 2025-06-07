vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VowpalWabbit/vowpal_wabbit
    REF "${VERSION}"
    SHA512 f87229caf65c6c32fb863fa426a39592d41990a43ce4d79f0a076323e47cd3d1a8bd02884afceb662527c87d290e68c51df6263d6a97f3a044f3f7254a38f86a
    HEAD_REF master
    PATCHES
        cmake_remove_bin_targets.patch
        fix-build-error-with-fmt11.patch
        fix-external-libraries.patch
        fix-android-build.patch
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
        -DVW_STRING_VIEW_LITE_SYS_DEP=ON
        -DVW_SSE2NEON_SYS_DEP=ON
        -DVW_CXX_STANDARD=14 # boost-math require c++14
)
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/VowpalWabbit)
vcpkg_fixup_pkgconfig()
