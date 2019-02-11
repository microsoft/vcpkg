include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankheckenbach/ftgl
    REF 2.3.1
    SHA512 4c3c92e79371aa9048a0de6c27bd008036be19fe6179bce472f36ced359026aaeaa5b63c83f90ffc1d425dd2e587479efc700dc1082c2ed0189d16ea87838c9a
    HEAD_REF master
    PATCHES "0001-fix-building-DLL-on-Windows.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
vcpkg_test_cmake(PACKAGE_NAME FTGL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ftgl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ftgl/COPYING ${CURRENT_PACKAGES_DIR}/share/ftgl/copyright)
