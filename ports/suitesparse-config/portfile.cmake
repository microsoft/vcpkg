vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.13.0
    SHA512 62319607ddd06bdb160d1308233bccec2bafb8a4909d4f5123df1b1d1088d2df9290b21984f7963ec87c2502ee9c4d5e687b23bf9dcd13e2ff076a416b4e0eef
    HEAD_REF dev
)

set(PACKAGE_NAME SuiteSparse_config)

# Avoid overriding of BLA_VENDOR and skip straight to find_package() as done here
# https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/v7.8.1/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake#L240-L245
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/SuiteSparseBLAS.cmake"
    "${SOURCE_PATH}/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake"
    COPYONLY
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp SUITESPARSE_USE_OPENMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/${PACKAGE_NAME}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DSUITESPARSE_USE_CUDA=OFF  # not applicable here, skip check
        -DSUITESPARSE_USE_STRICT=ON  # don't allow implicit dependencies
        -DSUITESPARSE_USE_FORTRAN=OFF  # use Fortran sources translated to C instead
        -DSUITESPARSE_DEMOS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# Move SuiteSparseBLAS.cmake, SuiteSparsePolicy.cmake etc files
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/SuiteSparse" "${CURRENT_PACKAGES_DIR}/share/suitesparse")

vcpkg_cmake_config_fixup(
    PACKAGE_NAME ${PACKAGE_NAME}
    CONFIG_PATH lib/cmake/${PACKAGE_NAME}
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
