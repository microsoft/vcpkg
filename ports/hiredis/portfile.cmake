vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF "v${VERSION}"
    SHA512 0273e17d69919013a5ad0b400bd527c0f42dfd529777e059a3994803520b4229f6da77da89ab2d41b021ce8a7e5a43bd1ea8357cda8dc1fb8b50845cba5285a7
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
