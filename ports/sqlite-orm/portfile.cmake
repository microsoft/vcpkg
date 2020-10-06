# header-only library

set(FEATURE_PATCHES)

if(test IN_LIST FEATURES)
    list(APPEND FEATURE_PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-test-feature.patch)
endif()

if(example IN_LIST FEATURES)
    list(APPEND FEATURE_PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-example-feature.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fnc12/sqlite_orm
    REF b30ddc6a50dc582c93cd49d8d0cf8f5025ba1d2b # 1.5
    SHA512 faeeef88aef11e89e9565850c23087925fb4d75ef48a16434055f18831db8e230d044c81574d840dacca406d7095cb83a113afc326996e289ab11a02d8caa2f4
    HEAD_REF master
    PATCHES 
        fix-build-error.patch
        fix-usage.patch
        ${FEATURE_PATCHES}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    test SqliteOrm_BuildTests
    example BUILD_EXAMPLES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DSQLITE_ORM_ENABLE_CXX_17=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sqlite_orm TARGET_PATH share/SqliteOrm)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)