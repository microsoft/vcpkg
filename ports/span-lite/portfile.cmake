vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/span-lite
    REF v0.7.0
    SHA512 af1a47e10a3c061e6476845e54fe22341a353c0326dbbc35922edc248dbd55c3e62e5e0d1de5b5509a391515d792a5b35c8265bc1bcbbfb39a2e60c30a2fabcf
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
