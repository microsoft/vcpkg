vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.8.1
    SHA512 d07709ad8567e5fe954f04d0c38a95a5610394aaa5ff5c809518c378b937d20556114b95c9dc052b316c8e8fcbb2eca294b425b21e8bbfa5c04f72c6f15a5eb6
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Mongoose/Doc/License.txt")
