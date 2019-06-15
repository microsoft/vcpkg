include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF 6ccfcc2dce48c0d430b45064d0e13c962a64c42f
    SHA512 441950d541f626a2e668efab4ed429c453534ef0334aad410013f07870a4a99e347f7a7eed335d77af41f02ce3dd600564d982e4c976a0c4cb76c19b1231d39e
    HEAD_REF master
    PATCHES
        missing_usize64.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DINSTALL_DOCS=0 -DINSTALL_PKG_CONFIG_MODULE=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ogg TARGET_PATH share/ogg)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libogg RENAME copyright)
