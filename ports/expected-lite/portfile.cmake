vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/expected-lite
    REF v0.5.0
    SHA512 6dd8974d518db0c79fe7bd0e407a85436c6ad222f8e5ed84efb34925d9a665b5b83ff08529b3e985034ed9a9201c80575f6a956132408ef6577c9c47cac55eae
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DEXPECTED_LITE_OPT_BUILD_TESTS=OFF
        -DEXPECTED_LITE_OPT_BUILD_EXAMPLES=OFF
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
