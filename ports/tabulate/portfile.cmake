# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/tabulate
    REF 8f7a31b58806384b755858fe5e69593f9f216ed0
    SHA512 33a51617d363f9e8eed2153f60c5a087ed84edaeb21a0bc779d0af6228d4d7deb211e03c1eb7c8d56ac538de6a1cc0b641d219b4ff95d277f3daa7762f64a8f6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dtabulate_BUILD_TESTS=OFF
        -DSAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE.termcolor DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
