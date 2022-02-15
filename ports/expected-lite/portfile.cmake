vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/expected-lite
    REF v0.5.0
    SHA512 6dd8974d518db0c79fe7bd0e407a85436c6ad222f8e5ed84efb34925d9a665b5b83ff08529b3e985034ed9a9201c80575f6a956132408ef6577c9c47cac55eae
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEXPECTED_LITE_OPT_BUILD_TESTS=OFF
        -DEXPECTED_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright
)
