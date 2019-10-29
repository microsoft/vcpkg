include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libideviceactivation
    REF de6008a6bd66a96bb11468b8b137704f0fef2c54 # v1.2.137
    SHA512 cdf72702c465cb3e405db067fa96e2979b8c32e7798bcdb9e7286c4bc9392639cb0d31622c321453f635ef5212e645d300f3b420a847fb16fa05425c4882be95
    HEAD_REF msvc-master
    PATCHES libcurl_d.patch
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libideviceactivation.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    USE_VCPKG_INTEGRATION
    ALLOW_ROOT_INCLUDES
)

file(REMOVE ${CURRENT_PACKAGES_DIR}/include/Makefile.am)
