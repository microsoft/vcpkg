vcpkg_buildpath_length_warning(37)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libeigen/eigen
    REF 729443409942a1816ddf74b95224003b83f4925c # unreleased v3.4.90 (Apr 25, 2025)
    SHA512 8a465111994c3b45316a534408365223524c0fb4d9738cb8d674a8496a66c4ea95afb22094d48d8ed716cd3b4a99f08741d1eb798d9cf6e0995047fecb9c11df
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DEIGEN_BUILD_DOC=OFF
        -DEIGEN_BUILD_DEMOS=OFF
        -DEIGEN_BUILD_PKGCONFIG=ON
        -DEIGEN_BUILD_CMAKE_PACKAGE=ON
        -DEIGEN_BUILD_BLAS=ON
        -DEIGEN_BUILD_LAPACK=ON
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
