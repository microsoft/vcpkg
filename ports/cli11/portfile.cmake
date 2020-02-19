vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF dd0d8e4fe729e5b1110232c7a5c9566dad884686 #version 1.9.0
    SHA512 dccee89de994d17537b31db717d0f42cae8827a192067718641a6e9e3188f468047a86ce329781142b9c7a1216d5eedcfe975fdbd001f40005a8ab50e08470d9
    HEAD_REF master
    PATCHES fix-GtestSubmodule.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCLI11_TESTING=OFF
        -DCLI11_EXAMPLES=OFF
        -DENABLE_DOCS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CLI11)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
