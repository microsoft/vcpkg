vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/pe-parse
    REF v1.2.0
    SHA512 916ec515585ba1e83e2c6ae29667fd25bd4cac90c39e587ae6847dc9d503186e8853bd80f4e2a99177a3214f5c51eceff85fa610cadbc2bc1d3a79251e8ce942
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_COMMAND_LINE_TOOLS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pe-parse TARGET_PATH share/pe-parse)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(
    INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/pe-parse"
    RENAME copyright
)
