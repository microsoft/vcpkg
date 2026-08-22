vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.13.0
    SHA512 62319607ddd06bdb160d1308233bccec2bafb8a4909d4f5123df1b1d1088d2df9290b21984f7963ec87c2502ee9c4d5e687b23bf9dcd13e2ff076a416b4e0eef
    HEAD_REF dev
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Mongoose"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DSUITESPARSE_USE_CUDA=OFF
        -DSUITESPARSE_USE_STRICT=ON
        -DSUITESPARSE_USE_FORTRAN=OFF
        -DSUITESPARSE_DEMOS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python=ON  # Only used for tests
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME SuiteSparse_Mongoose
    CONFIG_PATH lib/cmake/SuiteSparse_Mongoose
)
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES suitesparse_mongoose AUTO_CLEAN)
if (NOT "tools" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Mongoose/Doc/License.txt")
