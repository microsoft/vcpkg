include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankheckenbach/ftgl
    REF 483639219095ad080538e07ceb5996de901d4e74
    SHA512 5a0d05dbb32952e5aa81d2537d604192ca19710cd57289ae056acc5e3ae6d403d7f0ffc8cf6c1aada6c3c23a8df4a8d0eabb81433036ade810bca1894fdfde54
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
