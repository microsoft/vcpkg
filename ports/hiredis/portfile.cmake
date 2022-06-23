if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(HIREDIS_PATCHES support-static.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF v1.0.2
    SHA512 86497a1c21869bbe535378885eee6dbd594ef96325966511a3513f81e501af0f5ac7fed864f3230372f3ac7a23c05bad477fa5aa90b9747c9fb1408028174f9b
    HEAD_REF master
    PATCHES
        fix-feature-example.patch
        fix-timeval.patch
        fix-include-path.patch
        fix-ssize_t.patch
        ${HIREDIS_PATCHES}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     ENABLE_SSL
        example ENABLE_EXAMPLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
if("ssl" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME hiredis_ssl CONFIG_PATH share/hiredis_ssl)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
