vcpkg_buildpath_length_warning(37)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libeigen/eigen
    REF ${VERSION}
    SHA512 15b540d2fad25de837d7612456ea65b7fcfa25f886c48dcb3de025e079f5f43f45f1c0bd9a8435430d0e2fb9f0a6129719626dd4fd45dc61fc480f97762b2f56
    HEAD_REF master
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
        -DEIGEN_BUILD_SPBENCH=OFF
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

# Copy the eigen header files to conventional location for user-wide MSBuild integration
file(GLOB INCLUDES ${CURRENT_PACKAGES_DIR}/include/eigen3/*)
file(COPY ${INCLUDES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING.README"
        "${SOURCE_PATH}/COPYING.APACHE"
        "${SOURCE_PATH}/COPYING.BSD"
        "${SOURCE_PATH}/COPYING.MINPACK"
        "${SOURCE_PATH}/COPYING.MPL2"
)
