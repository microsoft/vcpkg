vcpkg_buildpath_length_warning(37)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libeigen/eigen
    REF 3.3.8
    SHA512  5b4b5985b0294e07b3ed1155720cbbfea322fe9ccad0fc8b0a10060b136a9169a15d5b9cb7a434470cadd45dff0a43049edc20d2e1070005481a120212edc355
    HEAD_REF master
    PATCHES fix-cuda-error.patch # issue https://gitlab.com/libeigen/eigen/-/issues/1526
    PATCHES remove-error-counting-exception.patch # issue https://gitlab.com/libeigen/eigen/-/issues/2011 Hopefully to be addressed in 3.3.9
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DEIGEN_BUILD_PKGCONFIG=ON
    OPTIONS_RELEASE
        -DCMAKEPACKAGE_INSTALL_DIR=share/eigen3
        -DPKGCONFIG_INSTALL_DIR=lib/pkgconfig
    OPTIONS_DEBUG
        -DCMAKEPACKAGE_INSTALL_DIR=share/eigen3
        -DPKGCONFIG_INSTALL_DIR=lib/pkgconfig
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING.README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
