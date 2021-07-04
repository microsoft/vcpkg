# header-only library

set(FEATURE_PATCHES)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF 4c6a46bd4dcfba14a650e0fafb86331526878587 # 1.6
    SHA512 9626fc20374aff5da718d32c7b942a7a6434920da9cf68df6146e9c25cca61936c2e3091c6476c369c8bf241dcb8473169ee726eaedfeb92d79ff4fa8a6b2d32
    HEAD_REF master
    PATCHES 
        fix-features-build-error.patch
        fix-dependency.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test BUILD_TESTING
    example BUILD_EXAMPLES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DSQLITE_ORM_ENABLE_CXX_17=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SqliteOrm TARGET_PATH share/SqliteOrm)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)