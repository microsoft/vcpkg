if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF v1.0.0
    SHA512 eb56201121eecdbfc8d42e8c2c141ae77bea248eeb36687ac6835c9b2404f5475beb351c4d8539d552db4d88e933bb2bd5b73f165e62b130bb11aeff39928e69
    HEAD_REF master
    PATCHES
        fix-feature-example.patch
        support-static-in-win.patch
        fix-timeval.patch
        fix-include-path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ssl     ENABLE_SSL
    example ENABLE_EXAMPLES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets()
if("ssl" IN_LIST FEATURES)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/hiredis_ssl TARGET_PATH share/hiredis_ssl)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)