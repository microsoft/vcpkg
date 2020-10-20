vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v3.1.2
    SHA512 d43df19d9e8652291f1301a326ec0d592bad43d6ecf9086947037f0ae0c1e70c2d96082c48066639e2b7c57c0ea0e4782d6b215d017cf96a4c73ff3a15feec75
    HEAD_REF master
    PATCHES fix-test.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUTF8_INSTALL=ON
        -DUTF8_SAMPLES=OFF
        -DUTF8_TESTS=OFF
)

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/utf8cpp)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/utf8cpp TARGET_PATH share/utf8cpp)
endif()

# Header only
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)