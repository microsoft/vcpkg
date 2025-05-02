vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF "v${VERSION}"
    SHA512 e6e9f7e617bf1d03bdf64a80e74ed24816b6c71607b976757a9962ae02a3b65be7006d84fd353dd5a63c8d0ef1ed385c3b73851b4a119c5ed48f3f86437cf250
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
