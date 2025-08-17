vcpkg_buildpath_length_warning(37)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libeigen/eigen
    REF eb57d4bdf1052f27bc575a8850dbc63eec6e9870 # from 3.4 branch on Aug 17, 2025 (3.4.1-250817)
    SHA512 6c7d7b12492d24d3c25e39a04322d9182b1f6f78ed617a1bc4086cca14b1673cf5b9f8e67dd4bb7db5e0544cf24928e2afbe27af094761a65cc61bc6fd20fdab
    HEAD_REF master
    PATCHES
        restore-include-dir.patch   # Restore EIGEN3_INCLUDE_DIR variable to match the 3.4.0 behavior
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DEIGEN_BUILD_BLAS=OFF
        -DEIGEN_BUILD_BTL=OFF
        -DEIGEN_BUILD_CMAKE_PACKAGE=ON
        -DEIGEN_BUILD_DEMOS=OFF
        -DEIGEN_BUILD_DOC=OFF
        -DEIGEN_BUILD_LAPACK=OFF
        -DEIGEN_BUILD_PKGCONFIG=ON
        -DEIGEN_BUILD_SPBENCH=ON
    OPTIONS_RELEASE
        "-DCMAKEPACKAGE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}"
        "-DPKGCONFIG_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
    OPTIONS_DEBUG
        "-DCMAKEPACKAGE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}"
        "-DPKGCONFIG_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING.README"
        "${SOURCE_PATH}/COPYING.APACHE"
        "${SOURCE_PATH}/COPYING.BSD"
        "${SOURCE_PATH}/COPYING.MINPACK"
        "${SOURCE_PATH}/COPYING.MPL2"
)
