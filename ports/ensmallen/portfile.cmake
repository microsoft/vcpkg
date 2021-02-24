vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF 8d9c03715346f2048e61e3e370a6a6c7a5e55d3b # 2.14.2
    SHA512 2aebdd485265f8f6adcf9eb00c78e5f79f5d19e62566bdfcd024c44443d5658a7b92ea4ca62c29041f1b512cf67f8148fdc8b6894c9aa4c69ef305580916e24a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ensmallen TARGET_PATH share/ensmallen)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
