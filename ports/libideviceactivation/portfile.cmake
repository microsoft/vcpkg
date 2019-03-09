include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libideviceactivation
    REF 1.0.38
    SHA512 2fd2d5636e83a6740251dca58c04429628f47661a56e573fc14f45ef68c54990717515305902cf04759a7c8fd19e66a30c8eb2ea20e6257d2c5405b690ea25a6
    HEAD_REF msvc-master
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
