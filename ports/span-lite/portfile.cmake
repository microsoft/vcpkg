include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/span-lite
    REF v0.5.0
    SHA512 4221d9897736257077b8ff6a5246d70315bebb975a30a119778f22c1859d14cca5e3035447561ca9684bef6dbca5a00b3b5ca208dada4fcf1f3b31df2aa0cb1f
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSPAN_LITE_OPT_BUILD_TESTS=OFF
        -DSPAN_LITE_OPT_BUILD_EXAMPLES=OFF
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
