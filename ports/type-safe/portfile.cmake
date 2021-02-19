vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO foonathan/type_safe
    REF da1d15abc612afbdc81d70c817b49ba1752177de
    SHA512 5b344af89378e34f05d96bff2de61615bc16e21601d9fe9d0886c71db211bd3b42afb2467dd2eb7f3d11176dc9adc2d71c6dc0b60722e12aaf8c1d79ea869289
    HEAD_REF v0.2.1
    PATCHES
        disable_tests.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DTYPE_SAFE_BUILD_TEST_EXAMPLE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/type_safe TARGET_PATH share/type_safe)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
