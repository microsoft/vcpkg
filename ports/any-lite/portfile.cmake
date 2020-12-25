vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/any-lite
    REF v0.2.0
    SHA512 703900d7bac96d41f903b6cabba4bce15ef3cf7ef0a6a66de76230498ededff110e43d68d4a3fd6996869b2edd001f69bd53039a214d06b774ce99518f384a68
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DANY_LITE_OPT_BUILD_TESTS=OFF
        -DANY_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/${PORT}
)

file( REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file( INSTALL
    ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
