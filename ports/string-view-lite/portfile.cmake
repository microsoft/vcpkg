include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/string-view-lite
    REF v1.3.0
    SHA512 52fb76198249ade5352d95af4a4e305b3e22b464a5d0a702e4b2228b1ca30df98b90bb01d5bfd16ae6ebb7bab5aecac5bd4a867898c362e82e57c2aaf938e07a
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTRING_VIEW_LITE_OPT_BUILD_TESTS=OFF
        -DSTRING_VIEW_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
