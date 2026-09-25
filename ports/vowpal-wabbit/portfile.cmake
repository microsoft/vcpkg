vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VowpalWabbit/vowpal_wabbit
    REF "${VERSION}"
    SHA512 d31fb47e0d137d7f63daed7f8e20c41901416632fc5c3c9e9063ff4b003a784b3964418ef321bb670275c6463d1082e7523a8b5f3d09093c84565ec2ba6b913b
    HEAD_REF master
    PATCHES
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
        -DVW_BUILD_EXECUTABLES=OFF
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
