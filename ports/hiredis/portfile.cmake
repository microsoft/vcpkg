vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF "v${VERSION}"
    SHA512 f8984abb29c09e7e6b56e656616c5155f36c53da4161a2d4c85688486411cadcdf20aa1adb9bda208c500b401c750871be1c8d58ba9df5328634d00e9d1b6589
    HEAD_REF master
    PATCHES
        fix-timeval.patch
        fix-ssize_t.patch
        support-static.patch
        fix-cmake-conf-install-dir.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
      -DDISABLE_TESTS=ON
      -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup()
if("ssl" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME hiredis_ssl CONFIG_PATH share/hiredis_ssl)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hiredis/hiredis.h"
[[typedef long long ssize_t;
#define _SSIZE_T_ /* for compatibility with libuv */]]
[[typedef intptr_t ssize_t;]]
)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hiredis/sds.h"
[[typedef long long ssize_t;
#define SSIZE_MAX (LLONG_MAX >> 1)]]
[[typedef intptr_t ssize_t;
#define SSIZE_MAX INTPTR_MAX]]
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
