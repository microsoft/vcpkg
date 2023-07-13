vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF "v${VERSION}"
    SHA512 9dad012c144ed24de6aa413a3a10d19a9d0d9ece18dbc388406cd86c5b98cb66c76c586cb559c601ed13a75051d8921dc2882534cc3605513fde47d57276c3bb
    HEAD_REF master
    PATCHES
        fix-timeval.patch
        fix-ssize_t.patch
        support-static.patch
        fix-pdb-install.patch
        fix-cmake-conf-install-dir.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
      -DENABLE_EXAMPLES=OFF
      -DDISABLE_TESTS=ON
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
