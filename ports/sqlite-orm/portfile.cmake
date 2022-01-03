# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF v1.7.1
    SHA512 ab934959245e8e0aaefd543ef0c1ab336547e4c311aff9dda916c7577c006622dec917313350d0d8bde4366d42b458c915fc2ea2fb927c01910fe429e55c8bbc
    HEAD_REF master
    PATCHES 
        fix-features-build-error.patch
        fix-dependency.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test BUILD_TESTING
        example BUILD_EXAMPLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLITE_ORM_ENABLE_CXX_17=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME SqliteOrm CONFIG_PATH lib/cmake/SqliteOrm)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)