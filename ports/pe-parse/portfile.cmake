vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/pe-parse
    REF v1.3.0
    SHA512 b723e90821e0ac67b4d6b15e5a46cf13544f21380a4d2add013eedcaa309e1be2cff6789247397c6fb4a938e4a240a835cbe21c8221bd558a4fccf8e93ce1548
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_COMMAND_LINE_TOOLS=OFF
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
